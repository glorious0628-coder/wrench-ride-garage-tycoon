# Back-face check (pp-3d-make 10-20): faces seen from behind render magenta, from 11 angles incl. 5 deg grazing.
#   blender --background --factory-startup --python tools/blender/backface_views.py -- <file.glb> <out_dir>
# back faces in magenta (any face seen from behind), front faces grey, from low / side angles
import bpy, sys, os
from mathutils import Vector, Matrix
argv = sys.argv[sys.argv.index("--") + 1:]; glb, out = argv[0], os.path.abspath(argv[1]); os.makedirs(out, exist_ok=True)
# (absolute on purpose: with no .blend open, Blender writes a relative render path under the drive root, C:\art\...)
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=glb)
objs = [o for o in bpy.context.scene.objects if o.type == "MESH"]
m = bpy.data.materials.new("bf"); m.use_nodes = True; N = m.node_tree.nodes; L = m.node_tree.links
for n in list(N): N.remove(n)
o_ = N.new("ShaderNodeOutputMaterial"); g = N.new("ShaderNodeNewGeometry"); mix = N.new("ShaderNodeMixShader")
d = N.new("ShaderNodeBsdfDiffuse"); d.inputs[0].default_value = (0.6, 0.6, 0.6, 1); e = N.new("ShaderNodeEmission"); e.inputs[0].default_value = (1, 0, 1, 1)
L.new(g.outputs["Backfacing"], mix.inputs[0]); L.new(d.outputs[0], mix.inputs[1]); L.new(e.outputs[0], mix.inputs[2]); L.new(mix.outputs[0], o_.inputs[0])
for ob in objs: ob.data.materials.clear(); ob.data.materials.append(m)
sc = bpy.context.scene; sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = sc.render.resolution_y = 1200; sc.render.film_transparent = True
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for ob in objs:
    for c in ob.bound_box:
        w = ob.matrix_world @ Vector(c); lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
cen = (lo + hi) / 2; size = max(hi - lo)
ld = bpy.data.lights.new("s", "SUN"); ld.energy = 3; lo_ = bpy.data.objects.new("s", ld); sc.collection.objects.link(lo_); lo_.rotation_euler = (0.6, 0.2, 0.5)
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cd.ortho_scale = size * 1.4; cam = bpy.data.objects.new("c", cd); sc.collection.objects.link(cam); sc.camera = cam
for n, dv in (("low_front", (0.5, 1, -0.6)), ("low_side", (-1, 0.3, -0.5)), ("bottom", (0.01, 0.2, -1)), ("side_r", (1, 0.2, 0.1)), ("top_back", (0.2, -1, 0.9)), ("f_up5", (0, 1, -0.0875)), ("f_dn5", (0, 1, 0.0875)), ("l5", (-1, 0.0875, 0)), ("r5", (1, 0.0875, 0)), ("fl5", (-0.7, 0.7, -0.087)), ("fr5", (0.7, 0.7, 0.087))):
    dv = Vector(dv).normalized(); cam.location = cen + dv * size * 3; cam.rotation_euler = (-dv).to_track_quat("-Z", "Y").to_euler()
    sc.render.filepath = os.path.join(out, n + ".png"); bpy.ops.render.render(write_still=True)
