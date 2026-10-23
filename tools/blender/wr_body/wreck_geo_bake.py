# Wreck pass, step 1 (wr-3d-body, 10-21): bake GEOMETRY maps in each body part's own UV layout (the deliverable GLBs in
# B_concept), so the rust / peel / dust overlays can be computed per texel in numpy (wreck_maps.py):
#   pos  = car coords (x, Y, s) of the surface,   nrm = car-space normal,   seam = distance to the nearest panel seam
#   (the 'gap' grooves of every body part in the source blend),   cov = texel inside a UV island.
#   blender --background --factory-startup --python tools/blender/wr_body/wreck_geo_bake.py -- <B_concept> <sedan_body_B.blend> <out_dir>
import bpy, bmesh, sys, os
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

a = sys.argv[sys.argv.index("--") + 1:]
DEL, SRC, OUT = (os.path.abspath(p) for p in a[:3])
os.makedirs(OUT, exist_ok=True)
PARTS = {"Shell": ("sedan_shell", 2048), "Hood": ("sedan_hood", 1024), "Bumper_F": ("sedan_bumper_f", 1024),
         "Bumper_R": ("sedan_bumper_r", 1024), "Glass": ("sedan_glass", 256)}

# seam field source: 'gap' faces (panel grooves) of every body part
bpy.ops.wm.open_mainfile(filepath=SRC)
bs = bmesh.new()
for o in bpy.context.scene.objects:
    if o.type != 'MESH' or o.name not in ("Shell", "Hood", "Bumper_F", "Bumper_R"):
        continue
    gi = [i for i, m in enumerate(o.data.materials) if m and m.name.startswith("gap")]
    b = bmesh.new(); b.from_mesh(o.data); b.transform(o.matrix_world)
    kill = [f for f in b.faces if f.material_index not in gi]
    bmesh.ops.delete(b, geom=kill, context='FACES')
    me = bpy.data.meshes.new("tmp"); b.to_mesh(me); b.free(); bs.from_mesh(me)
SEAM = BVHTree.FromBMesh(bs)
print("seam faces", len(bs.faces))

bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.render.engine = 'CYCLES'; sc.cycles.samples = 1; sc.cycles.device = 'CPU'
sc.render.bake.margin = 6; sc.render.bake.use_clear = True


def bake_map(ob, tex, name, socket_fn, margin=6):
    im = bpy.data.images.new(name, tex, tex, alpha=False, float_buffer=True); im.colorspace_settings.name = 'Non-Color'
    m = bpy.data.materials.new(name); m.use_nodes = True; nt = m.node_tree; N = nt.nodes
    for n_ in list(N):
        N.remove(n_)
    out = N.new("ShaderNodeOutputMaterial"); em = N.new("ShaderNodeEmission")
    nt.links.new(socket_fn(nt), em.inputs["Color"]); nt.links.new(em.outputs[0], out.inputs["Surface"])
    tn = N.new("ShaderNodeTexImage"); tn.image = im; N.active = tn
    ob.data.materials.clear(); ob.data.materials.append(m)
    sc.render.bake.margin = margin
    bpy.ops.object.bake(type='EMIT')
    arr = np.array(im.pixels[:], dtype=np.float32).reshape(tex, tex, 4)[::-1, :, :3]    # top row first (PNG order)
    return arr


def geo(nt, out):
    g = nt.nodes.new("ShaderNodeNewGeometry"); return g.outputs[out]


def enc(nt, sock, add, mul):            # (v + add) * mul -> 0..1
    vm = nt.nodes.new("ShaderNodeVectorMath"); vm.operation = 'ADD'; vm.inputs[1].default_value = (add,) * 3
    nt.links.new(sock, vm.inputs[0])
    vs = nt.nodes.new("ShaderNodeVectorMath"); vs.operation = 'SCALE'; vs.inputs["Scale"].default_value = mul
    nt.links.new(vm.outputs[0], vs.inputs[0]); return vs.outputs[0]


for part, (base, tex) in PARTS.items():
    for o in list(sc.objects):
        bpy.data.objects.remove(o)
    bpy.ops.import_scene.gltf(filepath=os.path.join(DEL, base + ".glb"))
    ob = [o for o in sc.objects if o.type == 'MESH'][0]
    ob.data.transform(ob.matrix_world); ob.matrix_world.identity()
    for o in sc.objects:
        o.select_set(o == ob)
    bpy.context.view_layer.objects.active = ob
    # seam distance per vertex -> colour attribute
    me = ob.data
    att = me.color_attributes.new("wr_seam", 'FLOAT_COLOR', 'POINT')
    for v in me.vertices:
        d = SEAM.find_nearest(v.co)[3] if SEAM.find_nearest(v.co)[0] is not None else 9.0
        att.data[v.index].color = (min(d, 4.0) / 4.0, 0, 0, 1)
    pos = bake_map(ob, tex, part + "_pos", lambda nt: enc(nt, geo(nt, "Position"), 10.0, 0.05))
    nrm = bake_map(ob, tex, part + "_nrm", lambda nt: enc(nt, geo(nt, "Normal"), 1.0, 0.5))

    def seam_sock(nt):
        at = nt.nodes.new("ShaderNodeAttribute"); at.attribute_name = "wr_seam"; return at.outputs["Color"]
    seam = bake_map(ob, tex, part + "_seam", seam_sock)

    def one(nt):
        rgb = nt.nodes.new("ShaderNodeRGB"); rgb.outputs[0].default_value = (1, 1, 1, 1); return rgb.outputs[0]
    cov = bake_map(ob, tex, part + "_cov", one, margin=0)
    P = pos / 0.05 - 10.0                                        # blender (x, y=-s, z=Y)
    np.save(os.path.join(OUT, part + "_pos.npy"), np.stack([P[..., 0], P[..., 2], -P[..., 1]], -1).astype(np.float32))
    Nn = nrm * 2.0 - 1.0
    np.save(os.path.join(OUT, part + "_nrm.npy"), np.stack([Nn[..., 0], Nn[..., 2], -Nn[..., 1]], -1).astype(np.float32))
    np.save(os.path.join(OUT, part + "_seam.npy"), (seam[..., 0] * 4.0).astype(np.float32))
    np.save(os.path.join(OUT, part + "_cov.npy"), (cov[..., 0] > 0.5))
    print("GEO", part, tex, "covered", round(float((cov[..., 0] > 0.5).mean()), 3))
print("GEO DONE")
