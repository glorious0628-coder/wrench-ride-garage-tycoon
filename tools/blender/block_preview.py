# Block + facade preview (pp-3d-field 10-20): renders Roblox blocks with their painted faces (Texture tiled every u x v
# studs, offset ou / ov — the way Modules/Facades.luau puts them on) so a facade can be checked before Studio: do the
# windows line up across blocks, half windows at the edges, the picture's size on the face.
#   blender --background --factory-startup --python tools/blender/block_preview.py -- <scene.json> <out_dir> [px=1024]
# scene.json (Roblox coordinates, studs):
#   {"parts": [{"name": "FrontWall", "size": [3.7, 12, 0.8], "pos": [9.15, 6.4, 34.9], "rot_y": 0, "color": "#ECEFF3",
#               "faces": {"Front": {"image": "C:/.../window.png", "u": 4, "v": 6, "ou": 0, "ov": 0}}}],
#    "front": "-Z"}            (the side the "front" camera looks at: -Z / +Z / -X / +X)
# Texture convention ASSUMED until pp-studio's check: U runs to the viewer's right from the face's top-left corner seen
# from outside, V runs down; OffsetStuds moves the picture's start that far into the face. Set "u_from": "right" /
# "v_from": "bottom" in a face to try the other corners.
# Writes front.png (ortho, straight on), threeq.png (3/4 from the front-left), threeq_r.png.
import bpy, sys, os, json, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
scene_p, out = os.path.abspath(argv[0]), os.path.abspath(argv[1])
PX = int(argv[2]) if len(argv) > 2 else 1024
os.makedirs(out, exist_ok=True)
S = json.load(open(scene_p, encoding="utf-8"))
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene


def rb(v):  # Roblox (x, y, z) -> Blender (x, -z, y)
    return Vector((v[0], -v[2], v[1]))


def hexc(h):
    h = h.lstrip("#")
    return tuple(((int(h[i:i + 2], 16) / 255) ** 2.2) for i in (0, 2, 4))


def flat_mat(name, col):
    m = bpy.data.materials.new(name); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (*col, 1); b.inputs["Roughness"].default_value = 0.7
    return m


def tex_mat(name, path):
    m = bpy.data.materials.new(name); m.use_nodes = True; N = m.node_tree.nodes; L = m.node_tree.links
    b = N["Principled BSDF"]; b.inputs["Roughness"].default_value = 0.7
    t = N.new("ShaderNodeTexImage"); t.image = bpy.data.images.load(path); t.extension = "REPEAT"; t.interpolation = "Linear"
    L.new(t.outputs["Color"], b.inputs["Base Color"]); L.new(t.outputs["Alpha"], b.inputs["Alpha"])
    m.blend_method = "BLEND" if hasattr(m, "blend_method") else None
    try:
        m.surface_render_method = "BLENDED"
    except Exception:
        pass
    return m


NORMALS = {"Front": (0, 0, -1), "Back": (0, 0, 1), "Left": (-1, 0, 0), "Right": (1, 0, 0), "Top": (0, 1, 0), "Bottom": (0, -1, 0)}
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for i, p in enumerate(S["parts"]):
    size = Vector(p["size"]); pos = Vector(p["pos"]); ry = math.radians(p.get("rot_y", 0))
    R = Matrix.Rotation(ry, 3, "Y")  # Roblox yaw about +Y
    bpy.ops.mesh.primitive_cube_add(size=1)
    ob = bpy.context.active_object; ob.name = p.get("name", "part%d" % i)
    ob.scale = (size.x, size.z, size.y)
    ob.location = rb(pos); ob.rotation_euler = (0, 0, ry)
    ob.data.materials.append(flat_mat("m%d" % i, hexc(p.get("color", "#A3A2A5"))))
    bpy.context.view_layer.update()  # (matrix_world is stale until the scene updates)
    for c in ob.bound_box:
        w = ob.matrix_world @ Vector(c); lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
    for face, f in (p.get("faces") or {}).items():
        n = R @ Vector(NORMALS[face])
        up = R @ Vector((0, 1, 0)) if face not in ("Top", "Bottom") else R @ Vector((0, 0, -1 if face == "Top" else 1))
        right = (-n).cross(up)  # the viewer's right, looking at the face from outside
        # face width / height (along right / up) from the size
        loc = {"Front": (size.x, size.y), "Back": (size.x, size.y), "Left": (size.z, size.y), "Right": (size.z, size.y), "Top": (size.x, size.z), "Bottom": (size.x, size.z)}[face]
        W, H = loc
        half = {"Front": size.z, "Back": size.z, "Left": size.x, "Right": size.x, "Top": size.y, "Bottom": size.y}[face] / 2
        c = pos + n * (half + 0.003)
        U, V = f.get("u", W), f.get("v", H)
        ou, ov = f.get("ou", 0.0), f.get("ov", 0.0)
        verts, uvs = [], []
        for s_, t_ in ((0, 0), (W, 0), (W, H), (0, H)):  # s from the left, t from the top (studs)
            pw = c + right * (s_ - W / 2) + up * (H / 2 - t_)
            verts.append(rb(pw))
            ss = (W - s_) if f.get("u_from") == "right" else s_
            tt = (H - t_) if f.get("v_from") == "bottom" else t_
            uvs.append(((ss + ou) / U, 1 - (tt + ov) / V))
        me = bpy.data.meshes.new("face"); me.from_pydata(verts, [], [(0, 1, 2, 3)]); me.update()
        uvl = me.uv_layers.new()
        for li, loop in enumerate(me.loops):
            uvl.data[li].uv = uvs[loop.vertex_index]
        fo = bpy.data.objects.new("face_" + face, me); sc.collection.objects.link(fo)
        if me.polygons[0].normal.dot(rb(n)) < 0:
            me.flip_normals()
        fo.data.materials.append(tex_mat("t%d%s" % (i, face), os.path.abspath(f["image"])))

sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = sc.render.resolution_y = PX; sc.render.film_transparent = True
sc.view_settings.view_transform = "Standard"
wd = bpy.data.worlds.new("w"); sc.world = wd; wd.use_nodes = True; wd.node_tree.nodes["Background"].inputs[1].default_value = 0.8
sun = bpy.data.lights.new("sun", "SUN"); sun.energy = 2.5; so = bpy.data.objects.new("sun", sun); sc.collection.objects.link(so)
cen = (lo + hi) / 2; size = max(hi - lo)
fr = {"-Z": Vector((0, 1, 0)), "+Z": Vector((0, -1, 0)), "-X": Vector((-1, 0, 0)), "+X": Vector((1, 0, 0))}[S.get("front", "-Z")]  # Blender dir to the camera
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cd.ortho_scale = size * 1.15
cam = bpy.data.objects.new("c", cd); sc.collection.objects.link(cam); sc.camera = cam
side = fr.cross(Vector((0, 0, 1)))
# the sun from above-front-left (shines onto the front faces), like a plaza afternoon
so.rotation_euler = (-(fr + side * 0.5 + Vector((0, 0, 1.3)))).normalized().to_track_quat("-Z", "Y").to_euler()
for nm, dv in (("front", fr), ("threeq", (fr + side * 0.8 + Vector((0, 0, 0.35))).normalized()), ("threeq_r", (fr - side * 0.8 + Vector((0, 0, 0.35))).normalized())):
    cam.location = cen + dv * size * 3; cam.rotation_euler = (-dv).to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(out, nm + ".png"); bpy.ops.render.render(write_still=True)
print("PREVIEW", out)
