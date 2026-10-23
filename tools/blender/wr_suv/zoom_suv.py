# Close-up render around a car-coord point (wr-3d-suv debug; copied from wr_body/zoom_render.py): blender ... -- <in.glb[;in2.glb]> <out.png> x Y s dirx diry dirz [scale] [mode]
import bpy, sys, os, math
from mathutils import Vector, Matrix
a = sys.argv[sys.argv.index("--") + 1:]
src, outp = a[0], os.path.abspath(a[1]); x, Y, s = map(float, a[2:5]); d = Vector(tuple(map(float, a[5:8]))).normalized()
scale = float(a[8]) if len(a) > 8 else 2.0; MODE = a[9] if len(a) > 9 else "grey"
bpy.ops.wm.read_factory_settings(use_empty=True)
for p in src.split(";"):
    bpy.ops.import_scene.gltf(filepath=p)
sc = bpy.context.scene
objs = [o for o in sc.objects if o.type == 'MESH']
m = bpy.data.materials.new("m"); m.use_nodes = True; N = m.node_tree.nodes; L = m.node_tree.links
for n in list(N):
    N.remove(n)
o_ = N.new("ShaderNodeOutputMaterial"); g = N.new("ShaderNodeNewGeometry"); mix = N.new("ShaderNodeMixShader")
dd = N.new("ShaderNodeBsdfPrincipled"); dd.inputs["Base Color"].default_value = (0.45, 0.45, 0.45, 1); dd.inputs["Roughness"].default_value = 0.35
e = N.new("ShaderNodeEmission"); e.inputs[0].default_value = (1, 0, 1, 1)
L.new(g.outputs["Backfacing"], mix.inputs[0]); L.new(dd.outputs[0], mix.inputs[1]); L.new(e.outputs[0], mix.inputs[2]); L.new(mix.outputs[0], o_.inputs[0])
COLS = {"Shell": (0.55, 0.55, 0.55), "Hood": (0.30, 0.45, 0.80), "Bumper_F": (0.85, 0.55, 0.20), "Bumper_R": (0.85, 0.30, 0.30),
        "Chassis": (0.25, 0.70, 0.30), "Glass": (0.08, 0.08, 0.10), "ReviewWheels": (0.20, 0.20, 0.20)}
for ob in objs:
    ob.data.materials.clear()
    if MODE == "parts":
        k = next((c for c in COLS if ob.name.startswith(c)), "Shell")
        mm = bpy.data.materials.new("p_" + ob.name); mm.use_nodes = True
        mm.node_tree.nodes["Principled BSDF"].inputs["Base Color"].default_value = (*COLS[k], 1)
        ob.data.materials.append(mm)
    else:
        ob.data.materials.append(m)
c = Vector((x, -s, Y))
for nm, en, dv in (("k", 2500, (-0.8, 1.0, 1.5)), ("f", 700, (1.3, 0.4, 0.35)), ("r", 900, (0.2, -1.4, 0.8))):
    ld = bpy.data.lights.new(nm, "AREA"); ld.energy = en; ld.size = 6
    lo = bpy.data.objects.new(nm, ld); sc.collection.objects.link(lo); dv = Vector(dv).normalized(); lo.location = c + dv * 12
    lo.rotation_euler = (-dv).to_track_quat("-Z", "Y").to_euler()
sc.world = bpy.data.worlds.new("w"); sc.world.use_nodes = True; sc.world.node_tree.nodes["Background"].inputs[1].default_value = 0.3
cd = bpy.data.cameras.new("c"); cd.type = "ORTHO"; cd.ortho_scale = scale; cam = bpy.data.objects.new("c", cd); sc.collection.objects.link(cam); sc.camera = cam
f = -d; r = f.cross(Vector((0, 0, 1))).normalized(); u = r.cross(f)
cam.matrix_world = Matrix.Translation(c + d * 30) @ Matrix(((r.x, u.x, -f.x, 0), (r.y, u.y, -f.y, 0), (r.z, u.z, -f.z, 0), (0, 0, 0, 1)))
cd.clip_end = 100
sc.render.engine = "BLENDER_EEVEE"; sc.render.resolution_x = sc.render.resolution_y = 900; sc.render.film_transparent = False
sc.view_settings.view_transform = "Standard"
sc.render.filepath = outp; bpy.ops.render.render(write_still=True)
