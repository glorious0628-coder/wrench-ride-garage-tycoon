# Builder preview: render the parts that tools/builder/export_parts.luau dumped (when Studio's own viewport can't be
# captured). Roblox coordinates, studs; the model's front faces -Z.
#   blender --background --factory-startup --python tools/builder/render_parts.py -- <parts.json> <out_dir> [px=1100]
# Writes front.png back.png left.png right.png (orthographic, straight on), threeq.png (3/4 from front-left, eye a
# little above a player's head) and top.png.
import bpy, bmesh, sys, os, json, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
parts_p, out = os.path.abspath(argv[0]), os.path.abspath(argv[1])
PX = int(argv[2]) if len(argv) > 2 else 1100
os.makedirs(out, exist_ok=True)
P = json.load(open(parts_p, encoding="utf-8"))
bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene

M = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))  # Roblox (x, y, z) -> Blender (x, -z, y)


def srgb(h):
    return tuple(((int(h[i:i + 2], 16) / 255) ** 2.2) for i in (0, 2, 4))


mats = {}


def material(hexc, t, mname):
    key = (hexc, round(t, 2), mname)
    if key in mats:
        return mats[key]
    m = bpy.data.materials.new("m%d" % len(mats)); m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    col = srgb(hexc)
    b.inputs["Base Color"].default_value = (*col, 1)
    rough = {"SmoothPlastic": 0.45, "Glass": 0.08, "Metal": 0.35, "Neon": 0.5}.get(mname, 0.8)
    b.inputs["Roughness"].default_value = rough
    if mname == "Metal":
        b.inputs["Metallic"].default_value = 0.6
    if mname == "Neon":
        b.inputs["Emission Color"].default_value = (*col, 1)
        b.inputs["Emission Strength"].default_value = 3.0
    if t > 0.01:
        b.inputs["Alpha"].default_value = max(0.05, 1 - t)
        try:
            m.surface_render_method = "BLENDED"
        except Exception:
            pass
    mats[key] = m
    return m


def local_verts_faces(kind, s):
    x, y, z = s[0] / 2, s[1] / 2, s[2] / 2
    if kind == "wedge":  # sloped face toward -Z, tall face at +Z
        v = [(-x, -y, -z), (x, -y, -z), (x, -y, z), (-x, -y, z), (-x, y, z), (x, y, z)]
        f = [(0, 1, 2, 3), (3, 2, 5, 4), (0, 3, 4), (1, 5, 2), (0, 4, 5, 1)]
        return v, f
    v = [(-x, -y, -z), (x, -y, -z), (x, y, -z), (-x, y, -z), (-x, -y, z), (x, -y, z), (x, y, z), (-x, y, z)]
    f = [(0, 1, 2, 3), (5, 4, 7, 6), (4, 0, 3, 7), (1, 5, 6, 2), (3, 2, 6, 7), (4, 5, 1, 0)]
    return v, f


lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for i, p in enumerate(P):
    if p["n"] == "SandboxGround":
        continue
    c = p["cf"]; pos = Vector(c[0:3]); R = Matrix((c[3:6], c[6:9], c[9:12]))
    s = p["s"]; kind = p["k"]
    me = bpy.data.meshes.new("me%d" % i)
    if kind in ("cyl", "ball"):
        bm = bmesh.new()
        r = min(s[1], s[2]) / 2
        if kind == "cyl":
            bmesh.ops.create_cone(bm, cap_ends=True, segments=24, radius1=r, radius2=r, depth=s[0],
                                  matrix=Matrix.Rotation(math.radians(90), 4, "Y"))
        else:
            bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=r)
        bm.to_mesh(me); bm.free()
    else:
        v, f = local_verts_faces(kind, s)
        me.from_pydata(v, [], f)
    # vertices are in Roblox-local axes; world (Blender) = M @ (R @ v + pos)
    W = Matrix.Identity(4)
    W3 = M @ R
    for a in range(3):
        for b_ in range(3):
            W[a][b_] = W3[a][b_]
    t = M @ pos
    W[0][3], W[1][3], W[2][3] = t
    me.transform(W)
    ob = bpy.data.objects.new(p["n"], me); sc.collection.objects.link(ob)
    ob.data.materials.append(material(p["c"], p.get("t", 0), p.get("m", "")))
    for vv in me.vertices:
        lo = Vector(map(min, lo, vv.co)); hi = Vector(map(max, hi, vv.co))

# ground
bpy.ops.mesh.primitive_plane_add(size=400, location=(0, 0, -0.001))
g = bpy.context.active_object; g.data.materials.append(material("8a8a8e", 0, "Concrete"))

center = (lo + hi) / 2; ext = hi - lo
w = sc.world or bpy.data.worlds.new("w"); sc.world = w; w.use_nodes = True
w.node_tree.nodes["Background"].inputs[0].default_value = (0.92, 0.94, 0.97, 1)
w.node_tree.nodes["Background"].inputs[1].default_value = 0.9
sun = bpy.data.lights.new("sun", "SUN"); sun.energy = 3.2; sun.angle = math.radians(8)
so = bpy.data.objects.new("sun", sun); sc.collection.objects.link(so)
so.rotation_euler = (math.radians(50), math.radians(-18), math.radians(-30))
sc.render.engine = "CYCLES"; sc.cycles.samples = 48; sc.cycles.use_denoising = True
sc.view_settings.view_transform = "Standard"
sc.render.film_transparent = False

cam_d = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cam_d); sc.collection.objects.link(cam); sc.camera = cam


def look(frm, to):
    d = (Vector(to) - Vector(frm)); cam.location = frm
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def shot(name, frm, ortho_scale=None, w=PX, h=None, lens=40):
    sc.render.resolution_x = w; sc.render.resolution_y = h or w
    if ortho_scale:
        cam_d.type = "ORTHO"; cam_d.ortho_scale = ortho_scale
    else:
        cam_d.type = "PERSP"; cam_d.lens = lens
    look(frm, center)
    sc.render.filepath = os.path.join(out, name + ".png")
    bpy.ops.render.render(write_still=True)


big = max(ext.x, ext.y, ext.z) * 1.12
D = 200
# Blender: front of the building is Roblox -Z = Blender +Y
shot("front", (center.x, center.y + D, center.z), big)
shot("back", (center.x, center.y - D, center.z), big)
shot("left", (center.x - D, center.y, center.z), big)   # building's own left = Roblox -X side seen from -X
shot("right", (center.x + D, center.y, center.z), big)
shot("top", (center.x, center.y + 0.01, center.z + D), big)
shot("threeq", (center.x - ext.x * 1.1, center.y + ext.x * 1.6, 4.5), None, lens=30)
print("rendered to", out)
