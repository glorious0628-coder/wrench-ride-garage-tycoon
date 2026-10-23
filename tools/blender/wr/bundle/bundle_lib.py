# Helpers for the bought-bundle background cars (wr-3d, 10-21).
# Blender frame after glTF import: +Y = car front (glTF -Z), +Z = up, +X = car right. 1 BU = 1 stud.
import bpy, os, math, json
from mathutils import Vector, Matrix

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
A3D = os.path.join(ROOT, "art", "3d")
WHEEL_KEYS = ("FL", "FR", "RL", "RR")


def srgb_to_lin(c):
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def hex_lin(h):
    h = h.lstrip("#")
    return tuple(srgb_to_lin(int(h[i:i + 2], 16) / 255) for i in (0, 2, 4))


def import_glb(path):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(path))
    return [o for o in bpy.data.objects if o not in before]


def mesh_points(objs, pred=None):
    """world-space vertex positions (evaluated) of the given objects"""
    dg = bpy.context.evaluated_depsgraph_get(); pts = []
    for o in objs:
        if o.type != 'MESH':
            continue
        ev = o.evaluated_get(dg); me = ev.to_mesh(); mw = ev.matrix_world
        for v in me.vertices:
            pts.append(mw @ v.co)
        ev.to_mesh_clear()
    return pts


def bbox(objs):
    pts = mesh_points(objs)
    lo = Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    hi = Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    return lo, hi


def wheel_key(name):
    n = name.upper()
    for k in WHEEL_KEYS:
        if n == k or n.startswith(k + "_") or n.startswith(k + "."):
            return k
    return None


def tri_count(objs):
    dg = bpy.context.evaluated_depsgraph_get(); t = 0
    for o in objs:
        if o.type == 'MESH':
            ev = o.evaluated_get(dg); me = ev.to_mesh(); t += sum(len(p.vertices) - 2 for p in me.polygons); ev.to_mesh_clear()
    return t


def car_frame(meshes):
    """origin = ground under the middle of the two axles (x = wheel centre line). Returns (origin, wheel info)"""
    wh = {}
    for o in meshes:
        k = wheel_key(o.name)
        if k:
            lo, hi = bbox([o]); wh[k] = ((lo + hi) / 2, hi.z - lo.z, hi.x - lo.x)
    if len(wh) == 4:
        fy = (wh["FL"][0].y + wh["FR"][0].y) / 2; ry = (wh["RL"][0].y + wh["RR"][0].y) / 2
        cx = sum(w[0].x for w in wh.values()) / 4
        gz = min(w[0].z - w[1] / 2 for w in wh.values())
        return Vector((cx, (fy + ry) / 2, gz)), wh
    lo, hi = bbox(meshes)
    return Vector(((lo.x + hi.x) / 2, (lo.y + hi.y) / 2, lo.z)), wh


def place_bundle_car(path, name, length=None, scale=None, loc=(0, 0, 0), rot_z=0.0, keep_origin=False):
    """import a bundle car, put its origin on the ground between the axles, scale uniformly (to `length` studs
    or by `scale`), parent everything to an empty `name`. Returns (empty, meshes, info)"""
    new = import_glb(path)
    meshes = [o for o in new if o.type == 'MESH']
    org, wh = car_frame(meshes)
    if keep_origin:
        org = Vector((0, 0, 0))
    lo, hi = bbox(meshes)
    s = scale if scale is not None else length / (hi.y - lo.y)
    E = bpy.data.objects.new(name, None); bpy.context.scene.collection.objects.link(E)
    for o in new:
        if o.parent is None:
            mw = o.matrix_world.copy()
            o.parent = E; o.matrix_parent_inverse = Matrix.Identity(4)
            o.matrix_basis = Matrix.Translation(-org) @ mw
    E.scale = (s, s, s); E.location = loc; E.rotation_euler = (0, 0, rot_z)
    bpy.context.view_layer.update()
    return E, meshes, {"scale": s, "orig_size_m": [hi.x - lo.x, hi.y - lo.y, hi.z - lo.z]}


def measure_car(meshes, glass_pred, wheel_pred=None):
    """numbers in the car's current world frame (car must stand at its place with rot_z = 0):
    size, wheel diameter, wheelbase, track, floor height between the axles, side-glass band"""
    wheel_pred = wheel_pred or (lambda o: wheel_key(o.name) is not None)
    body = [o for o in meshes if not wheel_pred(o)]
    wheels = [o for o in meshes if wheel_pred(o)]
    lo, hi = bbox(meshes)
    out = {"L": hi.y - lo.y, "W": hi.x - lo.x, "H": hi.z - lo.z}
    if wheels:
        ws = []
        for o in wheels:
            a, b = bbox([o]); ws.append(((a + b) / 2, b.z - a.z))
        out["wheel_d"] = max(w[1] for w in ws)
        ys = sorted(w[0].y for w in ws); xs = sorted(w[0].x for w in ws)
        out["wheelbase"] = (ys[-1] + ys[-2]) / 2 - (ys[0] + ys[1]) / 2
        out["track"] = (xs[-1] + xs[-2]) / 2 - (xs[0] + xs[1]) / 2
        cy = sum(w[0].y for w in ws) / len(ws)
        half = out["wheelbase"] / 4
    else:
        cy = (lo.y + hi.y) / 2; half = 1.0
    # floor = lowest body point in the middle half of the wheelbase
    dg = bpy.context.evaluated_depsgraph_get(); fz = 1e9; gz0, gz1 = 1e9, -1e9; gpts = 0
    for o in body:
        ev = o.evaluated_get(dg); me = ev.to_mesh(); mw = ev.matrix_world
        nm = mw.to_3x3().inverted().transposed()
        for p in me.polygons:
            c = mw @ p.center
            if abs(c.y - cy) < half:
                for vi in p.vertices:
                    fz = min(fz, (mw @ me.vertices[vi].co).z)
            if glass_pred(o, p):
                n = (nm @ p.normal).normalized()
                if abs(n.x) > 0.75:      # side windows only
                    for vi in p.vertices:
                        z = (mw @ me.vertices[vi].co).z; gz0 = min(gz0, z); gz1 = max(gz1, z); gpts += 1
        ev.to_mesh_clear()
    out["floor"] = fz - lo.z
    if gpts:
        out["side_glass_z"] = [gz0 - lo.z, gz1 - lo.z]
        out["glass_frac"] = (gz1 - gz0) / out["H"]
        out["belt_frac"] = (gz0 - lo.z) / out["H"]
    return {k: (round(v, 3) if isinstance(v, float) else [round(x, 3) for x in v] if isinstance(v, list) else v) for k, v in out.items()}


def bundle_glass_pred(o, p):
    ms = o.material_slots
    if p.material_index < len(ms) and ms[p.material_index].material:
        return "window" in ms[p.material_index].material.name.lower()
    return False


# ---------- our sedan (B_concept) with paint + Detail wheels + lite brakes ----------
SEDAN_PARTS = ["shell", "glass", "hood", "bumper_f", "bumper_r", "chassis"]
PAINTED = {"shell", "hood", "bumper_f", "bumper_r"}


def paint_material(mat, mask_path, paint_hex):
    nt = mat.node_tree; N = nt.nodes; L = nt.links
    bsdf = next(n for n in N if n.type == 'BSDF_PRINCIPLED')
    link = bsdf.inputs["Base Color"].links[0] if bsdf.inputs["Base Color"].links else None
    if link is None:
        return
    src = link.from_socket
    tex = N.new("ShaderNodeTexImage"); tex.image = bpy.data.images.load(mask_path, check_existing=True)
    tex.image.colorspace_settings.name = "Non-Color"
    # use the same UV as the colour texture
    mix = N.new("ShaderNodeMix"); mix.data_type = 'RGBA'; mix.blend_type = 'MIX'
    mix.inputs[7].default_value = (*hex_lin(paint_hex), 1)
    L.new(tex.outputs["Color"], mix.inputs[0]); L.new(src, mix.inputs[6]); L.new(mix.outputs[2], bsdf.inputs["Base Color"])


def place_our_sedan(name="OurSedan", loc=(0, 0, 0), paint="#098FFC", rot_z=0.0):
    E = bpy.data.objects.new(name, None); bpy.context.scene.collection.objects.link(E)
    meshes = []
    bdir = os.path.join(A3D, "sedan_body", "B_concept")
    for part in SEDAN_PARTS:
        new = import_glb(os.path.join(bdir, "sedan_%s.glb" % part))
        for o in new:
            if o.type == 'MESH':
                meshes.append(o)
                if part in PAINTED:
                    for s in o.material_slots:
                        if s.material and s.material.use_nodes:
                            paint_material(s.material, os.path.join(bdir, "sedan_%s_paintmask.png" % part), paint)
            if o.parent is None:
                o.parent = E
    wdir = os.path.join(A3D, "wheel"); brdir = os.path.join(A3D, "brake")
    for k, x, y in (("FR", 3.25, 5.0), ("RR", 3.25, -5.0), ("FL", -3.25, 5.0), ("RL", -3.25, -5.0)):
        left = x < 0
        files = [os.path.join(wdir, "Rim.glb"), os.path.join(wdir, "Tire.glb"),
                 os.path.join(brdir, "Brake_Lite_L.glb" if left else "Brake_Lite.glb")]
        for f in files:
            new = import_glb(f)
            for o in new:
                if o.parent is None:
                    rot = math.pi if (left and "Brake_Lite" not in f) else 0.0
                    o.matrix_world = Matrix.Translation((x, y, 1.375)) @ Matrix.Rotation(rot, 4, 'Z') @ o.matrix_world
                    o.parent = E; o.matrix_parent_inverse = Matrix.Identity(4)
                if o.type == 'MESH':
                    o.name = "%s_%s" % (k, o.name); meshes.append(o)
    E.location = loc; E.rotation_euler = (0, 0, rot_z)
    bpy.context.view_layer.update()
    return E, meshes


def sedan_glass_pred(o, p):
    return o.name.lower().startswith("glass")


def sedan_wheel_pred(o):
    return wheel_key(o.name) is not None and ("Tire" in o.name or "Rim" in o.name)
