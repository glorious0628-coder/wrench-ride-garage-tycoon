# Topology view without the Wireframe-modifier miter spikes (3D helper 10-22). blender-asset-qa review_shots --mode wire
# uses WIREFRAME with even offset, which shoots long spikes out of acute corners of long thin strips (the 3.7-stud bevel
# strips of the rails / cushions) - not geometry (bbox, sliver check = 0). This draws the same wire with
# use_even_offset = False (no miter), over a light solid copy, Workbench.
#   blender -b <file.blend> -P wire_clean.py -- <out.png>
import bpy, sys, os, math
from mathutils import Vector
out = os.path.abspath(sys.argv[sys.argv.index("--") + 1])
sc = bpy.context.scene
obs = [o for o in sc.objects if o.type == 'MESH']
for o in obs:
    w = o.copy(); w.data = o.data; sc.collection.objects.link(w)
    m = w.modifiers.new("wire", 'WIREFRAME'); m.thickness = 0.004; m.use_even_offset = False; m.use_relative_offset = False
    m.use_replace = True
    w.color = (0.02, 0.02, 0.02, 1); o.color = (0.78, 0.78, 0.8, 1)
sc.render.engine = 'BLENDER_WORKBENCH'; sh = sc.display.shading
sh.light = 'STUDIO'; sh.color_type = 'OBJECT'; sh.show_cavity = False
sc.render.film_transparent = False
w = bpy.data.worlds.new("w"); sc.world = w; w.color = (1, 1, 1)
sc.render.resolution_x, sc.render.resolution_y = 1600, 1000
cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam")); sc.collection.objects.link(cam); sc.camera = cam
cam.data.lens = 50
cam.location = Vector((4.2, -4.8, 3.3)); cam.rotation_euler = (Vector((0, -0.2, 0.25)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
sc.render.filepath = out; bpy.ops.render.render(write_still=True)
# a caster close up
cam.location = Vector((1.9, -2.4, 0.55)); cam.rotation_euler = (Vector((0.855, -1.53, 0.14)) - cam.location).to_track_quat('-Z', 'Y').to_euler()
sc.render.resolution_x, sc.render.resolution_y = 1000, 800
sc.render.filepath = out.replace(".png", "_caster.png"); bpy.ops.render.render(write_still=True)
print("WIRE_OK", out)
