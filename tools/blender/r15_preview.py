# Headless Blender: the default blocky R15 as blocks (measured, art/3d/r15/r15_block_measured_10-20.txt) wearing a classic
# Shirt + Pants (585x559 templates) and a head strip (tools/r15_clothes.py bake -> <out>_head.png, faces F R B L U D at 128 px),
# rendered orthographic from the 6 views of our concept sheets + a 3/4 view, transparent background, flat-ish light, so
# notes/design/3d_tools/concept_compare.py can overlay it on the concept (pp-3d-make 10-20, r15_npc_plan.md 2-4).
#   blender --background --factory-startup --python tools/blender/r15_preview.py -- <shirt.png> <pants.png> <head.png|-> <out_dir> [glb]
# Shirt draws over pants on the torso (alpha). Head '-' = plain skin-grey head. Output: front/back/left/right/top/bottom/q34.png
import bpy, bmesh, sys, os, math

argv = sys.argv[sys.argv.index("--") + 1:]
shirt_p, pants_p, head_p, out = [os.path.abspath(a) if a != "-" else a for a in argv[:4]]
want_glb = len(argv) > 4 and argv[4] == "glb"
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_homefile(use_empty=True)
sc = bpy.context.scene

TW, TH = 585.0, 559.0
TORSO = {"U": (231, 8, 128, 64), "R": (165, 74, 64, 128), "F": (231, 74, 128, 128), "L": (361, 74, 64, 128),
         "B": (427, 74, 128, 128), "D": (231, 204, 128, 64)}
LIMB_R = {"U": (217, 289, 64, 64), "L": (19, 355, 64, 128), "B": (85, 355, 64, 128), "R": (151, 355, 64, 128),
          "F": (217, 355, 64, 128), "D": (217, 485, 64, 64)}
LIMB_L = {"U": (308, 289, 64, 64), "F": (308, 355, 64, 128), "L": (374, 355, 64, 128), "B": (440, 355, 64, 128),
          "R": (506, 355, 64, 128), "D": (308, 485, 64, 64)}
HEADSTRIP = {f: (128 * i, 0, 128, 128) for i, f in enumerate("FRBLUD")}

# Roblox (x = its right, y up, z = back) -> Blender (X = -x, Y = z, Z = y): a proper rotation (no mirror), Blender -Y = the
# character's front, Blender +X = its left.
BLOCKS = [  # name, roblox centre (x,y,z), size, regions, image key
    ("torso", (0, 3, 0), (2, 2, 1), TORSO, "shirt"),
    ("torso_pants", (0, 3, 0), (2.0, 2.0, 1.0), TORSO, "pants"),
    ("armR", (1.5, 2.977, 0), (1, 1.954, 1), LIMB_R, "shirt"),
    ("armL", (-1.5, 2.977, 0), (1, 1.954, 1), LIMB_L, "shirt"),
    ("legR", (0.5, 1, 0), (1, 2, 1), LIMB_R, "pants"),
    ("legL", (-0.5, 1, 0), (1, 2, 1), LIMB_L, "pants"),
    ("head", (0, 4.586, 0), (1.196, 1.203, 1.198), HEADSTRIP, "head"),
]


def face_uv(region, tw, th, corner_uv):
    x, y, w, h = region
    u0, u1 = x / tw, (x + w) / tw
    v0, v1 = 1 - (y + h) / th, 1 - y / th  # Blender v up
    cu, cv = corner_uv
    return (u0 + (u1 - u0) * cu, v0 + (v1 - v0) * cv)


def make_block(name, c, s, regions, img_key):
    # faces in Roblox terms with, for each face, its 4 corners as (sx, sy, sz) signs in the order
    # template (left-bottom, right-bottom, right-top, left-top) — orientation as r15_clothes.py's T table:
    # F: x along -X, up +Y | B: x along +X | L(-X side): x along +Z | R(+X side): x along -Z
    # U: x along -X, down the template = -Z (so template top = +Z) | D: x along -X, down = +Z (template top = -Z)
    F = {
        "F": [(1, -1, -1), (-1, -1, -1), (-1, 1, -1), (1, 1, -1)],
        "B": [(-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)],
        "L": [(-1, -1, -1), (-1, -1, 1), (-1, 1, 1), (-1, 1, -1)],
        "R": [(1, -1, 1), (1, -1, -1), (1, 1, -1), (1, 1, 1)],
        "U": [(1, 1, -1), (-1, 1, -1), (-1, 1, 1), (1, 1, 1)],
        "D": [(1, -1, 1), (-1, -1, 1), (-1, -1, -1), (1, -1, -1)],
    }
    tw, th = (768.0, 128.0) if img_key == "head" else (TW, TH)
    mesh = bpy.data.meshes.new(name)
    bm = bmesh.new()
    uvl = bm.loops.layers.uv.new("UV")
    pad = 0.002 if img_key == "torso_pants" else 0.0
    for fk, corners in F.items():
        vs = []
        for sx, sy, sz in corners:
            rx, ry, rz = c[0] + sx * (s[0] / 2 + pad), c[1] + sy * (s[1] / 2 + pad), c[2] + sz * (s[2] / 2 + pad)
            vs.append(bm.verts.new((-rx, rz, ry)))
        f = bm.faces.new(vs)
        for loop, cuv in zip(f.loops, [(0, 0), (1, 0), (1, 1), (0, 1)]):
            loop[uvl].uv = face_uv(regions[fk], tw, th, cuv)
    bm.normal_update()
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    ob = bpy.data.objects.new(name, mesh)
    sc.collection.objects.link(ob)
    return ob


def material(name, path, fallback=(0.75, 0.75, 0.78, 1)):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = 0.8
    if path and path != "-":
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.load(path)
        tex.interpolation = "Closest"
        nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
        nt.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
        # dithered (depth-tested) alpha: a see-through shirt shows the pants under it, never the far side of the body
        if hasattr(m, "surface_render_method"):
            m.surface_render_method = "DITHERED"
    else:
        bsdf.inputs["Base Color"].default_value = fallback
    return m


mats = {"shirt": material("shirt", shirt_p), "pants": material("pants", pants_p), "head": material("head", head_p)}
objs = []
for name, c, s, regions, key in BLOCKS:
    if name == "torso_pants":
        # the pants' torso sits a hair inside the shirt's, so a see-through shirt shows the pants
        s = (s[0] - 0.004, s[1] - 0.004, s[2] - 0.004)
    ob = make_block(name, c, s, regions, "head" if key == "head" else key)
    ob.data.materials.append(mats[key])
    objs.append(ob)

if want_glb:
    bpy.ops.export_scene.gltf(filepath=os.path.join(out, "r15_preview.glb"), export_format="GLB")

# light + cameras
sc.render.engine = "BLENDER_EEVEE" if "BLENDER_EEVEE" in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items] else "BLENDER_EEVEE_NEXT"
sc.render.film_transparent = True
sc.render.resolution_x, sc.render.resolution_y = 418, 627
w = bpy.data.worlds.new("w")
w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (1, 1, 1, 1)
w.node_tree.nodes["Background"].inputs[1].default_value = 0.9
sc.world = w
sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN"))
sun.data.energy = 1.6
sun.rotation_euler = (math.radians(50), 0, math.radians(-30))
sc.collection.objects.link(sun)

cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
cam.data.type = "ORTHO"
sc.collection.objects.link(cam)
sc.camera = cam
# same framing as tools/r15_underlay.py: 88 px per stud, feet 575 px down a 418x627 cell -> ortho scale = 627/88 (height)
k = 88.0
cam.data.sensor_fit = "VERTICAL"
cam.data.ortho_scale = 627 / k
mid_z = (627 / 2 - (627 - 575)) / k  # blender Z of the cell centre for side views (feet at 575 px)
VIEWS = {  # location, rotation (blender), up
    "front": ((0, -20, mid_z), (math.radians(90), 0, 0)),
    "back": ((0, 20, mid_z), (math.radians(90), 0, math.radians(180))),
    "left": ((20, 0, mid_z), (math.radians(90), 0, math.radians(90))),     # its left = Blender +X; front on the picture left
    "right": ((-20, 0, mid_z), (math.radians(90), 0, math.radians(-90))),
    "top": ((0, 0, 20), (0, 0, 0)),            # front (-Y) at the picture bottom
    "bottom": ((0, 0, -20), (math.radians(180), 0, 0)),  # front at the picture top
}
for v, (loc, rot) in VIEWS.items():
    cam.location = loc
    cam.rotation_euler = rot
    if v in ("top", "bottom"):
        cam.location = (0, 0, loc[2])
    sc.render.filepath = os.path.join(out, v + ".png")
    bpy.ops.render.render(write_still=True)
# 3/4 from the front-right, a little above
cam.data.ortho_scale = 7.5
import mathutils
cam.location = mathutils.Vector((-12, -12, 2.6 + 6))  # its front-right, a little above
cam.rotation_euler = (mathutils.Vector((0, 0, 2.6)) - cam.location).to_track_quat("-Z", "Y").to_euler()
sc.render.resolution_x = sc.render.resolution_y = 600
sc.render.filepath = os.path.join(out, "q34.png")
bpy.ops.render.render(write_still=True)
print("R15PREVIEW_OK", out)
