# Grip check (wr-3d 10-21): the tool GLB + an R15-hand-sized box (0.30 x 0.30 x 0.30) placed and turned by the json Grip
# (pos, axis = +X of the attachment, secondary_axis = +Y; Roblox part space -> Blender: (x, y, z) -> (x, -z, y)).
#   blender -b --factory-startup --python grip_check.py -- <tool.glb> <attachments.json> <out.png>
import bpy, sys, json, math
from mathutils import Vector, Matrix
a = sys.argv[sys.argv.index("--") + 1:]
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=a[0])
g = json.load(open(a[1], encoding="utf-8"))["Grip"]
def bl(v):
    return Vector((v[0], -v[2], v[1]))
p, ax, sec = bl(g["pos"]), bl(g["axis"]).normalized(), bl(g["secondary_axis"]).normalized()
third = ax.cross(sec).normalized(); sec = third.cross(ax).normalized()
bpy.ops.mesh.primitive_cube_add(size=0.30)
hand = bpy.context.active_object
hand.matrix_world = Matrix.Translation(p) @ Matrix(((ax.x, sec.x, third.x, 0), (ax.y, sec.y, third.y, 0), (ax.z, sec.z, third.z, 0), (0, 0, 0, 1)))
m = bpy.data.materials.new("skin"); m.use_nodes = True
b = m.node_tree.nodes["Principled BSDF"]; b.inputs["Base Color"].default_value = (1.0, 0.75, 0.55, 1); b.inputs["Alpha"].default_value = 0.45
m.blend_method = 'BLEND' if hasattr(m, "blend_method") else None
hand.data.materials.append(m)
# arrow along the grip axis (thin cylinder) so the direction is visible
bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.5, location=p + ax * 0.25)
arr = bpy.context.active_object; arr.rotation_euler = ax.to_track_quat('Z', 'Y').to_euler()
am = bpy.data.materials.new("arrow"); am.use_nodes = True; am.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (0.1, 0.4, 1, 1)
arr.data.materials.append(am)
sc = bpy.context.scene; sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = sc.render.resolution_y = 700
sc.render.film_transparent = False; sc.view_settings.view_transform = "Standard"
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True; sc.world.node_tree.nodes["Background"].inputs[0].default_value = (0.24, 0.25, 0.28, 1)
sun = bpy.data.lights.new("s", "SUN"); sun.energy = 3; so = bpy.data.objects.new("s", sun); sc.collection.objects.link(so); so.rotation_euler = (0.7, 0.2, 0.6)
objs = [o for o in sc.objects if o.type == 'MESH']
lo = Vector((1e9,) * 3); hi = Vector((-1e9,) * 3)
for o in objs:
    for c in o.bound_box:
        w = o.matrix_world @ Vector(c); lo = Vector(map(min, lo, w)); hi = Vector(map(max, hi, w))
cen = (lo + hi) / 2; size = max(hi - lo)
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cd.ortho_scale = size * 1.3; cam = bpy.data.objects.new("c", cd); sc.collection.objects.link(cam); sc.camera = cam
d = Vector((1, 1, 0.7)).normalized(); cam.location = cen + d * size * 3; cam.rotation_euler = (-d).to_track_quat("-Z", "Y").to_euler()
sc.render.filepath = a[2]; bpy.ops.render.render(write_still=True)
print("ok", a[2])
