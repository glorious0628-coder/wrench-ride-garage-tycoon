# Grey review renders of the SUV body (wr-3d-suv, 10-21; copied from wr_body/render_body.py). Strong raking key light so bumps / facets / gaps show.
#   blender --background --factory-startup --python tools/blender/wr_body/render_body.py -- <in.blend|in.glb> <out_dir> [px_per_stud=100] [mode]
# mode: "grey" (default: body mid grey, glass dark grey, so the windows read) | "flat" (everything one grey)
#       | "wb" (Workbench + back-face culling: a flipped face shows as a hole) | "bf" (back faces magenta)
# Ortho views use a FIXED scale and centre so pixels map to studs (for the concept overlay):
#   SUV spec box: s -8.15..8.45 (centre 0.15), Y 0..6.6 (centre 3.3). left/right: s -9.85..10.15 x Y -1.7..8.3
#   (2000 x 1000 at 100 px/stud), front/back: x -5..5 x Y -1.7..8.3, top/bottom: x -5..5 x s -9.85..10.15. Plus perspective 3/4 views (front-left like the hero concept, rear-right).
import bpy, sys, os, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
src, out = argv[0], os.path.abspath(argv[1])
PX = float(argv[2]) if len(argv) > 2 else 100.0
MODE = argv[3] if len(argv) > 3 else "grey"
VIEWS = argv[4].split(",") if len(argv) > 4 and argv[4] != "all" else None
RIG = argv[5] if len(argv) > 5 else "studio"     # studio | side (low raking light along the body side: crease check)
#                                                  | under (car on the lift: shop light from below + a top bounce)
os.makedirs(out, exist_ok=True)
if src.endswith(".blend"):
    bpy.ops.wm.open_mainfile(filepath=os.path.abspath(src))
    for o in list(bpy.context.scene.objects):
        if o.type != 'MESH' or o.name.startswith("Hood_open") or (o.name.startswith("ReviewWheels") and "nowheels" in sys.argv):
            bpy.data.objects.remove(o)
else:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    for p in src.split(";"):
        bpy.ops.import_scene.gltf(filepath=os.path.abspath(p))
sc = bpy.context.scene
objs = [o for o in sc.objects if o.type == 'MESH']


def mat(name, col, rough, alpha=1.0):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*col, 1); b.inputs["Roughness"].default_value = rough
    m.use_backface_culling = True
    return m


if MODE == "bf":
    m = bpy.data.materials.new("bf"); m.use_nodes = True; N = m.node_tree.nodes; L = m.node_tree.links
    for n in list(N):
        N.remove(n)
    o_ = N.new("ShaderNodeOutputMaterial"); g = N.new("ShaderNodeNewGeometry"); mix = N.new("ShaderNodeMixShader")
    d = N.new("ShaderNodeBsdfDiffuse"); d.inputs[0].default_value = (0.6, 0.6, 0.6, 1)
    e = N.new("ShaderNodeEmission"); e.inputs[0].default_value = (1, 0, 1, 1)
    L.new(g.outputs["Backfacing"], mix.inputs[0]); L.new(d.outputs[0], mix.inputs[1]); L.new(e.outputs[0], mix.inputs[2])
    L.new(mix.outputs[0], o_.inputs[0])
    for ob in objs:
        ob.data.materials.clear(); ob.data.materials.append(m)
elif MODE.startswith("keep"):      # keep the file's materials; keep:#RRGGBB recolours the 'paint' slot (preview)
    if ":" in MODE:
        hx = MODE.split(":")[1]
        c = [int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5)]
        c = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in c]
        for m in bpy.data.materials:
            if m.name.startswith("paint") and m.node_tree:
                b_ = m.node_tree.nodes.get("Principled BSDF")
                if b_:
                    b_.inputs["Base Color"].default_value = (*c, 1)
elif MODE == "parts":       # one colour per part (chassis poke-through / part split check)
    cols = {"Shell": (0.55, 0.55, 0.55), "Hood": (0.30, 0.45, 0.80), "Bumper_F": (0.85, 0.55, 0.20), "Bumper_R": (0.85, 0.30, 0.30),
            "Chassis": (0.25, 0.70, 0.30), "Glass": (0.08, 0.08, 0.10), "ReviewWheels": (0.20, 0.20, 0.20)}
    for ob in objs:
        k = next((c for c in cols if ob.name.startswith(c)), "Shell")
        ob.data.materials.clear(); ob.data.materials.append(mat("m_" + ob.name, cols[k], 0.4))
else:
    grey = mat("grey", (0.42, 0.42, 0.42), 0.32)
    dark = mat("glass_dark", (0.06, 0.065, 0.07), 0.08)
    for ob in objs:
        ob.data.materials.clear()
        ob.data.materials.append(dark if (MODE == "grey" and ob.name.startswith("Glass")) else grey)
tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objs)
print("TRIS", tris, [(o.name, sum(len(p.vertices) - 2 for p in o.data.polygons)) for o in objs])

sc.render.film_transparent = True
sc.view_settings.view_transform = "Standard"
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.92, 0.92, 0.92, 1); bg.inputs[1].default_value = 0.22
SIZE = 20.0
CEN = Vector((0, -0.15, 3.0))    # blender coords: x, -s, Y   (s centre 0.15)


def light(name, energy, d, size_=14):
    ld = bpy.data.lights.new(name, "AREA"); ld.energy = energy; ld.size = size_
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    d = Vector(d).normalized(); ob.location = CEN + d * 40
    ob.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()


if RIG == "under":
    light("key", 16000, (-0.6, 0.35, -1.0), 12)
    light("fill", 6000, (0.9, -0.5, -0.7), 12)
    light("top", 2500, (0.0, 0.2, 1.0))
elif RIG == "side":
    light("key", 30000, (-1.0, 0.55, 0.22), 10)  # low, from the front-left along the side: ridges catch it
    light("fill", 1500, (1.3, 0.4, 0.35))
    light("top", 3000, (0.0, 0.2, 1.0))
elif MODE in ("grey", "flat", "parts") or MODE.startswith("keep"):
    light("key", 21000, (-0.8, 1.0, 1.5))       # high raking key from the front-left
    light("fill", 3000, (1.3, 0.4, 0.35))
    light("rim", 5000, (0.2, -1.4, 0.8))
    light("under", 900, (0.0, 0.3, -1.0))
cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
# name: (direction from the centre to the camera, up, frame w x h in studs, frame centre (x, Y, s))
ORTHO = {
    "left": ((-1, 0, 0), (0, 0, 1), (20, 10), (0, 3.3, 0.15)),
    "right": ((1, 0, 0), (0, 0, 1), (20, 10), (0, 3.3, 0.15)),
    "front": ((0, 1, 0), (0, 0, 1), (10, 10), (0, 3.3, 0.15)),
    "back": ((0, -1, 0), (0, 0, 1), (10, 10), (0, 3.3, 0.15)),
    "top": ((0, 0, 1), (0, -1, 0), (10, 20), (0, 3.3, 0.15)),
    "bottom": ((0, 0, -1), (0, 1, 0), (10, 20), (0, 3.3, 0.15)),
}
PERSP = {
    "threeq_fl": ((-1.0, 1.05, 0.62), 1600, 1100),
    "threeq_rr": ((1.0, -1.05, 0.62), 1600, 1100),
    "threeq_fr": ((1.0, 1.05, 0.45), 1600, 1100),
    "threeq_low": ((-1.0, 0.8, 0.12), 1600, 1100),
    "threeq_rl": ((-1.0, -1.05, 0.62), 1600, 1100),
}


def aim(d, up, centre, dist):
    d = Vector(d).normalized(); f = -d; r = f.cross(Vector(up)).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix.Translation(centre + d * dist) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0),
                                                                        (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))


def setup_engine():
    if MODE == "wb":
        sc.render.engine = "BLENDER_WORKBENCH"; sh = sc.display.shading
        sh.light = "STUDIO"; sh.color_type = "SINGLE"; sh.single_color = (0.62, 0.62, 0.62)
        sh.show_cavity = True; sh.cavity_type = "BOTH"; sh.show_backface_culling = True; sh.show_specular_highlight = True
    else:
        sc.render.engine = "BLENDER_EEVEE"


setup_engine()
for name, (d, up, (fw, fh), (cx, cy, cs)) in ORTHO.items():
    if VIEWS and name not in VIEWS:
        continue
    cd.type = "ORTHO"; cd.ortho_scale = max(fw, fh); cd.clip_end = 200
    sc.render.resolution_x = int(fw * PX); sc.render.resolution_y = int(fh * PX)
    aim(d, up, Vector((cx, -cs, cy)), 60)
    sc.render.filepath = os.path.join(out, name + ".png"); bpy.ops.render.render(write_still=True)
# engine-bay views (hood open): like the bay concept (front-above) and a 3/4
PERSP2 = {
    "hero": ((-0.85, 1.15, 0.62), (0.0, -0.9, 2.5), 19.0, 1536, 1024, 28),      # ~ the hero concept camera
    "sq_fl": ((-1.0, 1.05, 0.62), (0.0, -0.15, 2.7), 36.0, 600, 600, 50),      # game-size checks (64 / 96 px)
    "sq_rr": ((1.0, -1.05, 0.62), (0.0, -0.15, 2.7), 36.0, 600, 600, 50),
    "bay_top": ((0.0, 0.52, 1.0), (0.0, 5.85, 3.2), 11.6, 1536, 1024, 50),     # SUV bay (2nd pass)
    "bay_34": ((-0.75, 0.85, 0.95), (0.0, 5.7, 3.1), 15.0, 1600, 1100, 50),
    "bay_top2x": ((0.0, 0.52, 1.0), (0.0, 5.85, 3.2), 11.6, 3072, 2048, 50),
    "prop_side": ((1.0, 0.8, 0.25), (1.6, 6.35, 5.3), 13.0, 1400, 1000, 50),
    "wreck_corner_fl": ((-1.0, 1.0, 0.45), (-2.5, 7.3, 1.9), 7.0, 1400, 1000, 50),    # dented bumper + cracked lamp
    "tyre_fl": ((-1.0, 0.45, 0.12), (-3.25, 5.0, 1.0), 6.2, 1200, 1000, 50),          # flat tyre
    # car on the lift at 'Under' (+6): eyes of a standing avatar about 1.4 below the car's ground plane
    # (blender coords: x, -s, Y) eye 1.4 below the car's ground plane, looking up ~55 deg at the front / rear axle,
    # and from beside the car (under_side)
    "under_front": ((1.0, -1.6, -2.3), (0.0, 4.85, 0.9), 2.98, 1600, 1100, 18),   # SUV axles +-4.85
    "under_rear": ((-1.0, 1.6, -2.3), (0.0, -5.05, 0.9), 2.98, 1600, 1100, 18),
    "under_side": ((1.6, 2.4, -2.2), (0.0, -1.2, 0.8), 3.63, 1600, 1100, 18),     # mid: tunnel, heat shield, tank
}
for name, (d, cen, dist, w, h, lens) in PERSP2.items():
    if not VIEWS or name not in VIEWS:
        continue
    cd.type = "PERSP"; cd.lens = lens; cd.sensor_width = 36; cd.clip_end = 300
    sc.render.resolution_x = w; sc.render.resolution_y = h
    aim(d, (0, 0, 1), Vector(cen), dist)
    sc.render.filepath = os.path.join(out, name + ".png"); bpy.ops.render.render(write_still=True)
for name, (d, w, h) in PERSP.items():
    if VIEWS and name not in VIEWS:
        continue
    cd.type = "PERSP"; cd.lens = 50; cd.sensor_width = 36; cd.clip_end = 300
    sc.render.resolution_x = int(w * PX / 100); sc.render.resolution_y = int(h * PX / 100)
    aim(d, (0, 0, 1), Vector((0, -0.15, 2.7)), 34)
    sc.render.filepath = os.path.join(out, name + ".png"); bpy.ops.render.render(write_still=True)
print("done", out)
