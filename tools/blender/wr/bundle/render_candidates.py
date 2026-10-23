# Candidate renders + numbers for the bought bundle cars (wr-3d bundle helper, 10-21).
#   blender --background --factory-startup --python render_candidates.py -- <list.txt> <out_dir> [res=1]
#   ... [res] [q]  (q = only the 3/4 view)
# list.txt: one "label|path/to/car.glb" per line. Per car writes <out>/<label>_q.png (3/4 front-left),
# <label>_f.png (front ortho), <label>_s.png (left side ortho) and appends a JSON line to <out>/stats.jsonl.
# Blender frame after glTF import: +Y = glTF -Z = car front (if the pack follows -Z), +Z = up, +X = right.
import bpy, sys, os, json, math
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
lst, out = argv[0], os.path.abspath(argv[1])
RES = float(argv[2]) if len(argv) > 2 else 1.0
QONLY = len(argv) > 3 and argv[3] == "q"   # only the 3/4 view (colour-variant sheets)
os.makedirs(out, exist_ok=True)
items = [l.strip().split("|") for l in open(lst, encoding="utf-8") if l.strip() and not l.startswith("#")]


def world_bbox(objs):
    lo = Vector((1e9, 1e9, 1e9)); hi = Vector((-1e9, -1e9, -1e9))
    dg = bpy.context.evaluated_depsgraph_get()
    for o in objs:
        ev = o.evaluated_get(dg); me = ev.to_mesh()
        for v in me.vertices:
            p = ev.matrix_world @ v.co
            lo = Vector(map(min, lo, p)); hi = Vector(map(max, hi, p))
        ev.to_mesh_clear()
    return lo, hi


def tris(objs):
    dg = bpy.context.evaluated_depsgraph_get(); t = 0
    for o in objs:
        ev = o.evaluated_get(dg); me = ev.to_mesh()
        t += sum(len(p.vertices) - 2 for p in me.polygons); ev.to_mesh_clear()
    return t


def setup_scene():
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE"
    sc.view_settings.view_transform = "Standard"
    sc.render.film_transparent = False
    w = bpy.data.worlds.new("w"); w.use_nodes = True; sc.world = w
    bg = w.node_tree.nodes["Background"]; bg.inputs[0].default_value = (0.86, 0.87, 0.89, 1); bg.inputs[1].default_value = 0.9
    sd = bpy.data.lights.new("sun", "SUN"); sd.energy = 3.2; sd.angle = math.radians(8)
    so = bpy.data.objects.new("sun", sd); sc.collection.objects.link(so)
    so.rotation_euler = (math.radians(50), 0, math.radians(-35))
    cd = bpy.data.cameras.new("cam"); cam = bpy.data.objects.new("cam", cd); sc.collection.objects.link(cam); sc.camera = cam
    # ground plane (shadow catcher look: light grey)
    bpy.ops.mesh.primitive_plane_add(size=200, location=(0, 0, 0))
    g = bpy.context.active_object; g.name = "ground"
    m = bpy.data.materials.new("ground"); m.use_nodes = True
    m.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.50, 0.51, 0.52, 1)
    m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = 0.9
    g.data.materials.append(m)
    return sc, cam


def aim(cam, d, centre, dist, up=(0, 0, 1)):
    d = Vector(d).normalized(); f = -d; r = f.cross(Vector(up)).normalized(); u = r.cross(f)
    cam.matrix_world = Matrix.Translation(centre + d * dist) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0),
                                                                        (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))


for label, path in items:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc, cam = setup_scene()
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(path))
    new = [o for o in bpy.data.objects if o not in before]
    meshes = [o for o in new if o.type == 'MESH']
    lo, hi = world_bbox(meshes)
    # stand on the ground: lift so min z = 0 (stats keep the raw numbers)
    root = [o for o in new if o.parent is None]
    for o in root:
        o.location.z -= lo.z
    bpy.context.view_layer.update()
    size = hi - lo
    cen = Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, (hi.z - lo.z) / 2))
    wheels = {}
    for o in meshes:
        nm = o.name.upper()
        for k in ("FL", "FR", "RL", "RR"):
            if nm == k or nm.startswith(k + "_") or nm.startswith(k + "."):
                wl, wh = world_bbox([o]); wheels[k] = [round(v, 3) for v in ((wl + wh) / 2)] + [round(wh.z - wl.z, 3), round(wh.x - wl.x, 3)]
    mats = sorted({s.material.name for o in meshes for s in o.material_slots if s.material})
    st = {"label": label, "path": path, "size_xyz": [round(v, 3) for v in size], "min": [round(v, 3) for v in lo],
          "max": [round(v, 3) for v in hi], "tris": tris(meshes), "objects": [o.name for o in meshes], "mats": mats, "wheels": wheels}
    with open(os.path.join(out, "stats.jsonl"), "a", encoding="utf-8") as f:
        f.write(json.dumps(st) + "\n")
    L = max(size.x, size.y, size.z)
    # 3/4 front-left (front = +Y)
    cam.data.type = "PERSP"; cam.data.lens = 50; cam.data.clip_end = 500
    sc.render.resolution_x = int(560 * RES); sc.render.resolution_y = int(400 * RES)
    aim(cam, (-1.0, 1.15, 0.55), cen, L * 1.55)
    sc.render.filepath = os.path.join(out, label + "_q.png"); bpy.ops.render.render(write_still=True)
    if QONLY:
        print("DONE", label, st["size_xyz"], st["tris"]); continue
    # front ortho
    cam.data.type = "ORTHO"; cam.data.ortho_scale = max(size.x, size.z) * 1.15
    sc.render.resolution_x = int(280 * RES); sc.render.resolution_y = int(280 * RES)
    aim(cam, (0, 1, 0), cen, L * 3)
    sc.render.filepath = os.path.join(out, label + "_f.png"); bpy.ops.render.render(write_still=True)
    # left side ortho
    cam.data.ortho_scale = max(size.y, size.z) * 1.1
    sc.render.resolution_x = int(420 * RES); sc.render.resolution_y = int(280 * RES)
    aim(cam, (-1, 0, 0), cen, L * 3)
    sc.render.filepath = os.path.join(out, label + "_s.png"); bpy.ops.render.render(write_still=True)
    print("DONE", label, st["size_xyz"], st["tris"])
