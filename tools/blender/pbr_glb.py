# Headless Blender: put base colour + packed ORM (G roughness, B metal) on the reduced mesh and export a PBR GLB.
#   blender --background --factory-startup --python pbr_glb.py -- mesh.glb base.png orm.png out.glb [turn]
#   turn = 1 (pp-3d-make 10-20): spin 180 deg about up so Hunyuan's +Z front becomes the game's -Z front.
import bpy, sys
argv = sys.argv[sys.argv.index("--") + 1:]
src, basep, ormp, out = argv[:4]
turn = len(argv) > 4 and argv[4] == "1"
bpy.ops.wm.read_homefile(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
bpy.context.view_layer.objects.active = ob; ob.select_set(True)
mat = bpy.data.materials.new("pbr"); mat.use_nodes = True
nt = mat.node_tree; N = nt.nodes; L = nt.links
for n in list(N): N.remove(n)
o = N.new("ShaderNodeOutputMaterial"); b = N.new("ShaderNodeBsdfPrincipled"); L.new(b.outputs[0], o.inputs["Surface"])
tb = N.new("ShaderNodeTexImage"); tb.image = bpy.data.images.load(basep); L.new(tb.outputs["Color"], b.inputs["Base Color"])
to = N.new("ShaderNodeTexImage"); to.image = bpy.data.images.load(ormp); to.image.colorspace_settings.name = 'Non-Color'
sp = N.new("ShaderNodeSeparateColor"); L.new(to.outputs["Color"], sp.inputs[0])
L.new(sp.outputs["Green"], b.inputs["Roughness"]); L.new(sp.outputs["Blue"], b.inputs["Metallic"])
ob.data.materials.clear(); ob.data.materials.append(mat)
if turn:
    import math
    ob.rotation_euler[2] += math.pi
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True)
print("EXPORTED", out)
