# Headless Blender: take a (Hunyuan) GLB, reduce to a triangle budget, Smart-UV it, then project the 6-view concept
# images onto it (orthographic, each view weighted by how much the surface faces that view) and bake the result
# into a base-colour texture on the UVs. Output: <out>.glb (reduced mesh + UVs) and <out>_proj.png (baked colour).
# Args after --: src.glb out_prefix tris views.json
#   views.json: {"size": 600, "views": {"front": ["path", ox, oy, w, h], "back": [...], "left": [...], "right": [...],
#                "top": [...], "bottom": [...]}}  (ox, oy, w, h = the object's box in that square image, top-left origin)
import bpy, sys, json, time, os, math

argv = sys.argv[sys.argv.index("--") + 1:]
src, out, budget, vj = argv[0], argv[1], int(argv[2]), argv[3]
cfg = json.load(open(vj, encoding="utf-8"))
S = cfg["size"]
bpy.ops.wm.read_homefile(use_empty=True)
t0 = time.time()
bpy.ops.import_scene.gltf(filepath=src)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
bpy.context.view_layer.objects.active = ob; ob.select_set(True)
bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.remove_doubles(threshold=0.0005); bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.object.mode_set(mode='OBJECT')
tris = sum(len(p.vertices) - 2 for p in ob.data.polygons)
if tris > budget:
    d = ob.modifiers.new("dec", 'DECIMATE'); d.ratio = (budget - 30) / tris
    bpy.ops.object.modifier_apply(modifier="dec")
bpy.ops.object.shade_smooth()
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.uv.smart_project(angle_limit=1.15, island_margin=0.015)
bpy.ops.object.mode_set(mode='OBJECT')
xs = [v.co.x for v in ob.data.vertices]; ys = [v.co.y for v in ob.data.vertices]; zs = [v.co.z for v in ob.data.vertices]
bb = {"x": (min(xs), max(xs)), "y": (min(ys), max(ys)), "z": (min(zs), max(zs))}
print("TRIS", sum(len(p.vertices) - 2 for p in ob.data.polygons), "BBOX", {k: (round(a, 3), round(b, 3)) for k, (a, b) in bb.items()})

# ---- projection material
mat = bpy.data.materials.new("proj"); mat.use_nodes = True
nt = mat.node_tree; N = nt.nodes; L = nt.links
for n in list(N): N.remove(n)
outn = N.new("ShaderNodeOutputMaterial")
emit = N.new("ShaderNodeEmission")
L.new(emit.outputs[0], outn.inputs["Surface"])
tc = N.new("ShaderNodeTexCoord")
sep = N.new("ShaderNodeSeparateXYZ"); L.new(tc.outputs["Object"], sep.inputs[0])
geo = N.new("ShaderNodeNewGeometry")
nsep = N.new("ShaderNodeSeparateXYZ"); L.new(geo.outputs["Normal"], nsep.inputs[0])


def lin(sock, a, b, flip=False):
    """(coord - a) / (b - a), optionally 1 - that"""
    m = N.new("ShaderNodeMapRange"); m.clamp = False
    L.new(sock, m.inputs["Value"])
    m.inputs["From Min"].default_value = b if flip else a
    m.inputs["From Max"].default_value = a if flip else b
    m.inputs["To Min"].default_value = 0.0; m.inputs["To Max"].default_value = 1.0
    return m.outputs[0]


def to_img(t, off, length, vertical):
    """normalised object coord t (0..1) -> image coord 0..1; image rows are top-down, Blender v is bottom-up"""
    m = N.new("ShaderNodeMapRange"); m.clamp = False
    L.new(t, m.inputs["Value"])
    m.inputs["From Min"].default_value = 0.0; m.inputs["From Max"].default_value = 1.0
    if vertical:  # t = 0 at the bottom of the object -> row off+length -> v = 1 - (off+length)/S
        m.inputs["To Min"].default_value = 1 - (off + length) / S; m.inputs["To Max"].default_value = 1 - off / S
    else:
        m.inputs["To Min"].default_value = off / S; m.inputs["To Max"].default_value = (off + length) / S
    return m.outputs[0]


X, Y, Z = sep.outputs[0], sep.outputs[1], sep.outputs[2]
NX, NY, NZ = nsep.outputs[0], nsep.outputs[1], nsep.outputs[2]
# glTF front (+Z) imports as Blender -Y. Front camera at -Y (image right = +X), back at +Y (right = -X),
# left = the object's own left = +X side (right = +Y), right view at -X (right = -Y),
# top looks down with the front at the picture's bottom (right = +X, up = +Y), bottom looks up with the front at the top
# (right = +X, up = -Y).
spec = {
    "front": (lin(X, *bb["x"]), lin(Z, *bb["z"]), NY, -1),
    "back": (lin(X, *bb["x"], flip=True), lin(Z, *bb["z"]), NY, +1),
    "left": (lin(Y, *bb["y"]), lin(Z, *bb["z"]), NX, +1),
    "right": (lin(Y, *bb["y"], flip=True), lin(Z, *bb["z"]), NX, -1),
    "top": (lin(X, *bb["x"]), lin(Y, *bb["y"]), NZ, +1),
    "bottom": (lin(X, *bb["x"]), lin(Y, *bb["y"], flip=True), NZ, -1),
}
P = float(cfg.get("power", 12))
acc_col = None; acc_w = None
for name, (u, v, nsock, sign) in spec.items():
    if name not in cfg["views"]:
        continue
    path, ox, oy, w, h = cfg["views"][name]
    img = bpy.data.images.load(path)
    tex = N.new("ShaderNodeTexImage"); tex.image = img; tex.extension = 'EXTEND'; tex.interpolation = 'Linear'
    comb = N.new("ShaderNodeCombineXYZ")
    L.new(to_img(u, ox, w, False), comb.inputs[0]); L.new(to_img(v, oy, h, True), comb.inputs[1])
    L.new(comb.outputs[0], tex.inputs["Vector"])
    # weight = max(0, sign * n)^P
    mul = N.new("ShaderNodeMath"); mul.operation = 'MULTIPLY'; L.new(nsock, mul.inputs[0]); mul.inputs[1].default_value = sign
    mx = N.new("ShaderNodeMath"); mx.operation = 'MAXIMUM'; L.new(mul.outputs[0], mx.inputs[0]); mx.inputs[1].default_value = 0.0
    pw = N.new("ShaderNodeMath"); pw.operation = 'POWER'; L.new(mx.outputs[0], pw.inputs[0]); pw.inputs[1].default_value = P
    sc = N.new("ShaderNodeVectorMath"); sc.operation = 'SCALE'; L.new(tex.outputs["Color"], sc.inputs[0]); L.new(pw.outputs[0], sc.inputs["Scale"])
    if acc_col is None:
        acc_col, acc_w = sc.outputs[0], pw.outputs[0]
    else:
        a = N.new("ShaderNodeVectorMath"); a.operation = 'ADD'; L.new(acc_col, a.inputs[0]); L.new(sc.outputs[0], a.inputs[1]); acc_col = a.outputs[0]
        b = N.new("ShaderNodeMath"); b.operation = 'ADD'; L.new(acc_w, b.inputs[0]); L.new(pw.outputs[0], b.inputs[1]); acc_w = b.outputs[0]
eps = N.new("ShaderNodeMath"); eps.operation = 'MAXIMUM'; L.new(acc_w, eps.inputs[0]); eps.inputs[1].default_value = 1e-4
inv = N.new("ShaderNodeMath"); inv.operation = 'DIVIDE'; inv.inputs[0].default_value = 1.0; L.new(eps.outputs[0], inv.inputs[1])
fin = N.new("ShaderNodeVectorMath"); fin.operation = 'SCALE'; L.new(acc_col, fin.inputs[0]); L.new(inv.outputs[0], fin.inputs["Scale"])
L.new(fin.outputs[0], emit.inputs["Color"])
bake = bpy.data.images.new("bake", 1024, 1024, alpha=False); bake.colorspace_settings.name = 'sRGB'
bt = N.new("ShaderNodeTexImage"); bt.image = bake; N.active = bt; bt.select = True
ob.data.materials.clear(); ob.data.materials.append(mat)

sc = bpy.context.scene
sc.render.engine = 'CYCLES'; sc.cycles.device = 'CPU'; sc.cycles.samples = 1
sc.view_settings.view_transform = 'Standard'
sc.render.bake.margin = 8
bpy.ops.object.bake(type='EMIT')
bake.filepath_raw = out + "_proj.png"; bake.file_format = 'PNG'; bake.save()
print("BAKED", out + "_proj.png", round(time.time() - t0, 1), "s")
# coverage mask: which texels belong to the mesh (white) vs empty UV space (black)
for l in list(emit.inputs["Color"].links): L.remove(l)
emit.inputs["Color"].default_value = (1, 1, 1, 1)
mask = bpy.data.images.new("mask", 1024, 1024, alpha=False)
mt = N.new("ShaderNodeTexImage"); mt.image = mask; N.active = mt
sc.render.bake.margin = 0
bpy.ops.object.bake(type='EMIT')
mask.filepath_raw = out + "_mask.png"; mask.file_format = 'PNG'; mask.save()

# export the reduced mesh with a plain material that uses the baked image (for the preview renderer)
for n in list(N): N.remove(n)
bsdf = N.new("ShaderNodeBsdfPrincipled"); o2 = N.new("ShaderNodeOutputMaterial"); L.new(bsdf.outputs[0], o2.inputs["Surface"])
ti = N.new("ShaderNodeTexImage"); ti.image = bpy.data.images.load(out + "_proj.png"); L.new(ti.outputs["Color"], bsdf.inputs["Base Color"])
bsdf.inputs["Roughness"].default_value = 0.45
bpy.ops.export_scene.gltf(filepath=out + ".glb", export_format='GLB', use_selection=True)
print("EXPORTED", out + ".glb", round(time.time() - t0, 1), "s")
