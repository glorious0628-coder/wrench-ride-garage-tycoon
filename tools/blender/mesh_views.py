# Grey renders of a Hunyuan mesh framed exactly like the 6-view concept cells (pp-3d-make 10-20), for flow_warp.py.
# Each view is orthographic, tight on the mesh's bbox (Hunyuan +Z front = Blender -Y after import), workbench studio
# light + cavity so creases (strap edges, sole line) show like in the concept. Writes <out_dir>/<view>.png (RGBA).
#   blender --background --factory-startup --python mesh_views.py -- <mesh.glb> <out_dir> [px=600]
import bpy, sys, os
from mathutils import Vector, Matrix

argv = sys.argv[sys.argv.index("--") + 1:]
src, out = argv[0], os.path.abspath(argv[1]); PX = int(argv[2]) if len(argv) > 2 else 600
os.makedirs(out, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
ob = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for v in ob.data.vertices:
    w = ob.matrix_world @ v.co; lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
c = (lo + hi) / 2; e = hi - lo; size = max(e)
sc = bpy.context.scene
sc.render.engine = "BLENDER_WORKBENCH"; sh = sc.display.shading
sh.light = "STUDIO"; sh.color_type = "SINGLE"; sh.single_color = (0.8, 0.8, 0.8)
sh.show_cavity = True; sh.cavity_type = "BOTH"; sh.cavity_ridge_factor = 1.0; sh.cavity_valley_factor = 1.5
sc.render.film_transparent = True; sc.view_settings.view_transform = "Standard"
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cam = bpy.data.objects.new("c", cd)
sc.collection.objects.link(cam); sc.camera = cam
# view: camera position dir, picture right axis, picture up axis (same as label_bake / project_bake)
V = {"front": ((0, -1, 0), (1, 0, 0), (0, 0, 1)), "back": ((0, 1, 0), (-1, 0, 0), (0, 0, 1)),
     "left": ((1, 0, 0), (0, 1, 0), (0, 0, 1)), "right": ((-1, 0, 0), (0, -1, 0), (0, 0, 1)),
     "top": ((0, 0, 1), (1, 0, 0), (0, 1, 0)), "bottom": ((0, 0, -1), (1, 0, 0), (0, -1, 0))}
for n, (d, r, u) in V.items():
    d, r, u = Vector(d), Vector(r), Vector(u)
    wr = abs(e.dot(r)); hu = abs(e.dot(u))
    cam.matrix_world = Matrix.Translation(c + d * size * 3) @ Matrix((
        (r.x, u.x, d.x, 0), (r.y, u.y, d.y, 0), (r.z, u.z, d.z, 0), (0, 0, 0, 1)))
    cd.ortho_scale = max(wr, hu); cd.clip_end = size * 10
    sc.render.resolution_x = max(8, round(PX * wr / max(wr, hu))); sc.render.resolution_y = max(8, round(PX * hu / max(wr, hu)))
    sc.render.filepath = os.path.join(out, n + ".png")
    bpy.ops.render.render(write_still=True)
print("done", out)
