# Merge single-mesh GLBs into one GLB (separate named mesh nodes, each node's origin kept = its pivot), wr-3d helper 10-21.
#   blender -b --factory-startup --python assemble.py -- <out.glb> <a.glb> [b.glb ...]
import bpy, sys, os

a = sys.argv[sys.argv.index("--") + 1:]
out, srcs = os.path.abspath(a[0]), a[1:]
bpy.ops.wm.read_factory_settings(use_empty=True)
for s in srcs:
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(s))
for o in list(bpy.data.objects):
    if o.type != 'MESH':
        bpy.data.objects.remove(o)
for o in bpy.context.scene.objects:
    o.select_set(True)
    o.data.name = o.name
    for m in o.data.materials:
        if m and not m.name.startswith(o.name):
            m.name = o.name + "_mat"
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True)
print("assembled", out, [o.name for o in bpy.context.scene.objects])
