# Review renders at a FIXED scale (px per stud) so they can be laid over a 6-view concept without resizing
# (wr-3d helper 10-21, from art/3d/floor_jack/jack_views.py). Several GLBs are loaded together (a part made of
# several meshes). Build frame: +Y = the part's front, +Z up.
#   blender -b --factory-startup --python part_views.py -- <out_dir> <grey|colour> <ppu> <w> <h> <cx> <cy> <cz> <views> <a.glb> [b.glb ...]
# cx cy cz = view centre in BUILD coords. views = comma list of front,back,left,right,top,bottom,threeq,threeq_back,
# threeq_low, or "dir:x/y/z:name" for any direction. grey writes eevee_<v>.png + wb_<v>.png (Workbench, back-face
# culling on: a flipped face shows as a hole); colour keeps the GLB materials (see-through bodies stay see-through).
import bpy, sys, os
from mathutils import Vector, Matrix

a = sys.argv[sys.argv.index("--") + 1:]
out, mode, ppu, W, H = os.path.abspath(a[0]), a[1], float(a[2]), int(a[3]), int(a[4])
cen = Vector((float(a[5]), float(a[6]), float(a[7])))
views = a[8].split(",")
glbs = a[9:]
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
for g in glbs:
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(g))
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
sc = bpy.context.scene
sc.render.resolution_x, sc.render.resolution_y = W, H
sc.view_settings.view_transform = "Standard"
sc.render.film_transparent = True
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True
bg = sc.world.node_tree.nodes["Background"]
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for o in objs:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c); lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
S = max(hi - lo)
if mode == "grey":
    grey = bpy.data.materials.new("grey"); grey.use_nodes = True
    b = grey.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (0.42, 0.42, 0.42, 1); b.inputs["Roughness"].default_value = 0.32
    grey.use_backface_culling = True
    for o in objs:
        o.data.materials.clear(); o.data.materials.append(grey)
    bg.inputs[0].default_value = (0.92, 0.92, 0.92, 1); bg.inputs[1].default_value = 0.25
else:
    bg.inputs[0].default_value = (1, 1, 1, 1); bg.inputs[1].default_value = 0.55
    for o in objs:
        for m in o.data.materials:
            if m:
                m.use_backface_culling = True
try:
    sc.eevee.taa_render_samples = 32
except Exception:
    pass


def light(name, energy, loc, sz, spread):
    ld = bpy.data.lights.new(name, "AREA"); ld.energy = energy * sz * sz; ld.size = sz * spread
    ob = bpy.data.objects.new(name, ld); sc.collection.objects.link(ob)
    ob.location = cen + Vector(loc) * sz * 3
    ob.rotation_euler = (-(Vector(loc))).to_track_quat("-Z", "Y").to_euler()


if mode == "grey":
    light("key", 260, (0.9, 1.0, 1.6), S, 1.2); light("fill", 50, (-1.4, 0.5, 0.3), S, 1.2); light("rim", 90, (0.0, -1.5, 0.8), S, 1.2)
else:
    light("key", 400, (0.8, 1.2, 1.4), S, 3); light("fill", 160, (-1.3, 0.6, 0.6), S, 3); light("rim", 160, (0.2, -1.4, 1.0), S, 3)
    light("under", 50, (0, 0.3, -1.4), S, 3)
cd = bpy.data.cameras.new("cam"); cd.type = "ORTHO"
cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
V = {"front": ((0, 1, 0), (0, 0, 1)), "back": ((0, -1, 0), (0, 0, 1)), "left": ((-1, 0, 0), (0, 0, 1)),
     "right": ((1, 0, 0), (0, 0, 1)), "top": ((0, 0, 1), (0, -1, 0)), "bottom": ((0, 0, -1), (0, -1, 0)),
     "threeq": ((1, 1, 0.8), (0, 0, 1)), "threeq_back": ((-1, -1, 0.8), (0, 0, 1)), "threeq_low": ((0.8, 1, 0.25), (0, 0, 1)),
     "threeq_left": ((-1, 1, 0.8), (0, 0, 1))}
# NOTE left = camera on the part's own LEFT (-X): the part's back shows on the image's right (handoff README:
# 'left = the object's own left'); top = looking down, front at the image bottom; bottom = looking up, back at the top


def shoot(name, d, up, prefix):
    d = Vector(d).normalized(); f = -d; r = f.cross(Vector(up)).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix.Translation(cen + d * 30) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0), (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))
    cd.ortho_scale = max(W, H) / ppu; cd.clip_end = 100
    sc.render.filepath = os.path.join(out, prefix + name + ".png"); bpy.ops.render.render(write_still=True)


def view_of(v):
    if v.startswith("dir:"):
        _, d, nm = v.split(":")
        x, y, z = [float(t) for t in d.split("/")]
        return nm, (x, y, z), ((0, 0, 1) if abs(z) < 0.95 else (0, 1, 0))
    d, up = V[v]
    return v, d, up


sc.render.engine = "BLENDER_EEVEE"
for v in views:
    nm, d, up = view_of(v)
    shoot(nm, d, up, "eevee_" if mode == "grey" else "")
if mode == "grey":
    sc.render.engine = "BLENDER_WORKBENCH"; sh = sc.display.shading
    sh.light = "STUDIO"; sh.color_type = "SINGLE"; sh.single_color = (0.62, 0.62, 0.62)
    sh.show_cavity = True; sh.cavity_type = "BOTH"; sh.show_backface_culling = True; sh.show_specular_highlight = True
    for v in views:
        nm, d, up = view_of(v)
        shoot(nm, d, up, "wb_")
print("done", out)
