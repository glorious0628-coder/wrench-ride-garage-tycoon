# Wreck pass, step 3 (wr-3d-body, 10-21): variant MESHES for the wreck state, same UVs as the originals so every texture
# (clean + wreck levels) fits them.
#   Bumper_F_Dented  - the colour Bumper_F with a crumpled front-left corner (concept sedan_wreck_front)
#   Tire_Flat        - the wheel helper's Tire.glb (read only) with a flattened bottom + bulging sidewalls, same height,
#                      same pivot (wheel centre) -> drop-in for any wheel
#   HeadlightCrack_L - a thin decal shell over the car-left headlamp end of the light bar + a crack texture (alpha)
#   blender --background --factory-startup --python tools/blender/wr_body/wreck_mesh.py -- <art/3d> <sedan_body_B.blend> <out_dir>
import bpy, bmesh, sys, os, math, json
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree

a = sys.argv[sys.argv.index("--") + 1:]
ART, SRC, OUT = (os.path.abspath(p) for p in a[:3])
os.makedirs(OUT, exist_ok=True)
DEL = os.path.join(ART, "sedan_body", "B_concept")
BL = lambda x, Y, s: Vector((x, -s, Y))
CAR = lambda v: (v.x, v.z, -v.y)
sm = lambda e0, e1, x: (lambda t: t * t * (3 - 2 * t))(min(1.0, max(0.0, (x - e0) / (e1 - e0))))
INFO = {}


def fresh():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    return bpy.context.scene


def imp(path):
    sc = bpy.context.scene; before = set(sc.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    obs = [o for o in sc.objects if o not in before and o.type == 'MESH']
    for o in obs:
        mw = o.matrix_world.copy(); o.parent = None; o.data.transform(mw); o.matrix_world = Matrix.Identity(4)
    for o in [o for o in sc.objects if o not in before and o.type != 'MESH']:
        bpy.data.objects.remove(o)
    return obs


def export(path, obs):
    for o in bpy.context.scene.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=True, export_yup=True)


# ------------------------------------------------------------------ 1. Bumper_F_Dented ------------------------------
fresh()
ob = imp(os.path.join(DEL, "sedan_bumper_f.glb"))[0]
me = ob.data
# outward normal at the dent centres (nearest outer face), all vertices (outer + inner skin) move together = no tearing
bm = bmesh.new(); bm.from_mesh(me); bm.faces.ensure_lookup_table(); tree = BVHTree.FromBMesh(bm)
DENTS = [((-3.15, 1.60, -7.72), 0.36, 0.70), ((-2.60, 2.05, -8.15), 0.13, 0.42), ((-3.35, 1.20, -7.25), 0.10, 0.40)]
moves = []
for c, depth, rad in DENTS:
    loc, nrm, idx, dist = tree.find_nearest(BL(*c))
    n_ = nrm.copy()
    if n_.dot(loc - BL(0, 1.5, -5.0)) < 0:
        n_ = -n_
    moves.append((loc, n_, depth, rad))
for v in me.vertices:
    d_tot = Vector()
    for loc, n_, depth, rad in moves:
        r = (v.co - loc).length
        w = math.exp(-(r / rad) ** 2)
        crinkle = 1.0 + 0.10 * math.sin(7.0 * (v.co.z - loc.z) + 4.0 * (v.co.x - loc.x))
        d_tot -= n_ * depth * w * crinkle
    # the corner sags back a little (pushed in by the hit)
    x, Y, s = CAR(v.co)
    # the hit corner is pressed back and shoved toward the grille (+x), fading out before the wheel arch edge
    k = sm(-2.6, -3.3, x) * sm(2.5, 1.4, Y) * sm(-6.9, -7.6, s)
    d_tot += Vector((0.16, 0.0, 0.0)) * k + Vector((0, -1, 0)) * (0.12 * k)
    # keep the edges that meet other parts where they are: wheel-arch edge, top edge under the lamp, radiator side
    g = sm(-6.75, -7.05, s) * sm(2.75, 2.35, Y) * sm(-2.25, -2.6, x)
    v.co += d_tot * g
bm.free()
ob.name = "Bumper_F_Dented"; me.name = "Bumper_F_Dented"
for o in bpy.context.scene.objects:          # shading follows the new shape (drop the imported custom normals)
    o.select_set(o == ob)
bpy.context.view_layer.objects.active = ob
try:
    bpy.ops.mesh.customdata_custom_splitnormals_clear()
except Exception as e:
    print("normals", e)
bpy.ops.object.shade_smooth_by_angle(angle=math.radians(40), keep_sharp_edges=True)
export(os.path.join(OUT, "sedan_bumper_f_dented.glb"), [ob])
INFO["Bumper_F_Dented"] = dict(file="sedan_bumper_f_dented.glb", replaces="Body/Bumper_F mesh (MeshId swap or a second part)",
                               note="same UVs, bolts, pivot and attachments as Bumper_F; textures: sedan_bumper_f_* (clean / wreckN)",
                               dents=[dict(centre=c, depth=d, radius=r) for c, d, r in DENTS], tris=len(me.polygons))
print("DENTED", INFO["Bumper_F_Dented"]["tris"])

# ------------------------------------------------------------------ 2. Tire_Flat ------------------------------------
fresh()
obs = imp(os.path.join(ART, "wheel", "Tire.glb"))
R0 = max(math.hypot(v.co.y, v.co.z) for o in obs for v in o.data.vertices)
RIM = min(math.hypot(v.co.y, v.co.z) for o in obs for v in o.data.vertices)
TH0 = math.radians(34); BLEND = math.radians(18); BULGE = 0.17
for o in obs:
    for v in o.data.vertices:
        y, z = v.co.y, v.co.z                       # blender: y = -forward, z = up (tyre axle = x)
        r = math.hypot(y, z)
        phi = abs(math.atan2(y, -z))                 # 0 at the bottom
        wr = min(1.0, max(0.0, (r - RIM) / (R0 - RIM)))
        f = sm(TH0 + BLEND, TH0, phi)
        dz = -f * r * (1 - math.cos(phi)) * wr ** 1.5     # tread pulled flat onto the ground line
        wb = math.exp(-(phi / math.radians(46)) ** 2) * math.exp(-((r - (RIM + 0.55 * (R0 - RIM))) / 0.27) ** 2)
        v.co.z += dz
        v.co.x += math.copysign(BULGE * wb, v.co.x) if abs(v.co.x) > 1e-4 else 0.0
for o in obs:
    o.name = "Tire_Flat"; o.data.name = "Tire_Flat"
xs = [v.co.x for o in obs for v in o.data.vertices]; zs = [v.co.z for o in obs for v in o.data.vertices]
export(os.path.join(OUT, "Tire_Flat.glb"), obs)
INFO["Tire_Flat"] = dict(file="Tire_Flat.glb", replaces="MechanicalParts/Wheel_XX tyre mesh (Tire.glb)", pivot="wheel centre (same as Tire)",
                         size=[round(max(xs) - min(xs), 3), round(max(zs) - min(zs), 3), 2 * round(R0, 3)],
                         note="bottom flattened onto the ground line (contact patch ~%.2f long), sidewalls bulge %.2f; "
                              "same height so no ride-height change is needed; left side = same mesh turned 180 deg about Y like Tire"
                              % (2 * R0 * math.sin(TH0), BULGE),
                         tris=sum(len(o.data.polygons) for o in obs))
print("FLAT", INFO["Tire_Flat"])

# ------------------------------------------------------------------ 3. HeadlightCrack_L (decal shell + texture) -----
bpy.ops.wm.open_mainfile(filepath=SRC)
sh = bpy.data.objects["Shell"]
li = [i for i, m in enumerate(sh.data.materials) if m and m.name.startswith("light_white")]
bm = bmesh.new(); bm.from_mesh(sh.data); bm.transform(sh.matrix_world); bm.normal_update()
keep = [f for f in bm.faces if f.material_index in li and CAR(f.calc_center_median())[0] < -1.55
        and f.normal.dot(Vector((0, 0, 1))) < 0.7 and CAR(f.normal)[2] < 0.3]
bmesh.ops.delete(bm, geom=[f for f in bm.faces if f not in keep], context='FACES')
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
bm.normal_update()
for v in bm.verts:
    v.co += v.normal * 0.006
nav = sum((f.normal * f.calc_area() for f in bm.faces), Vector()).normalized()
u_ax = nav.cross(Vector((0, 0, 1))).normalized(); v_ax = u_ax.cross(nav).normalized()
uv = bm.loops.layers.uv.new("UVMap")
co = [(v.co.dot(u_ax), v.co.dot(v_ax)) for v in bm.verts]
u0, u1 = min(c[0] for c in co), max(c[0] for c in co); v0, v1 = min(c[1] for c in co), max(c[1] for c in co)
span = max(u1 - u0, v1 - v0)
for f in bm.faces:
    for l in f.loops:
        l[uv].uv = ((l.vert.co.dot(u_ax) - u0) / span, (l.vert.co.dot(v_ax) - v0) / span)
for o in list(bpy.context.scene.objects):
    bpy.data.objects.remove(o)
me = bpy.data.meshes.new("HeadlightCrack_L"); bm.to_mesh(me); bm.free()
ob = bpy.data.objects.new("HeadlightCrack_L", me); bpy.context.scene.collection.objects.link(ob)
# crack texture: voronoi cell borders, denser near the impact point, + a dark broken chunk at the impact
T = 512; rng = np.random.default_rng(7)
uu, vv = np.meshgrid((np.arange(T) + 0.5) / T, (np.arange(T) + 0.5) / T)
imp_ = np.array([0.42, (v1 - v0) / span * 0.55])
ang = rng.uniform(0, 2 * np.pi, 70); rad = 0.02 + 0.30 * rng.uniform(0, 1, 70) ** 1.6
pts = imp_ + np.stack([np.cos(ang) * rad, np.sin(ang) * rad * 0.8], -1)
d = np.sqrt((uu[..., None] - pts[:, 0]) ** 2 + (vv[..., None] - pts[:, 1]) ** 2)
d.sort(-1)
edge = d[..., 1] - d[..., 0]
ri = np.sqrt((uu - imp_[0]) ** 2 + ((vv - imp_[1]) / 0.8) ** 2)
reach = np.clip(1.0 - ri / 0.34, 0, 1)
line = (edge < 0.004 + 0.006 * reach) & (reach > 0)
for k in range(9):                                            # a few radial cracks
    th = 2 * np.pi * k / 9 + 0.3
    dist = np.abs(-(uu - imp_[0]) * np.sin(th) + (vv - imp_[1]) * np.cos(th))
    along = (uu - imp_[0]) * np.cos(th) + (vv - imp_[1]) * np.sin(th)
    line |= (dist < 0.0035) & (along > 0) & (along < 0.18 + 0.12 * (k % 3) / 2)
th_ = np.arctan2(vv - imp_[1], uu - imp_[0])
hole = ri < 0.040 + 0.008 * np.sin(3 * th_ + 0.7) + 0.006 * np.sin(5 * th_ + 2.1)
img = np.zeros((T, T, 4), np.float32)
img[line] = (0.20, 0.22, 0.25, 0.92); img[hole] = (0.10, 0.10, 0.11, 1.0)
cl = (~line) & (~hole) & (reach > 0)                          # cloudy, scratched lens around the hit
img[cl, :3] = 1.0; img[cl, 3] = 0.10 * reach[cl]
bim = bpy.data.images.new("sedan_headlight_crack_L", T, T, alpha=True)
bim.pixels[:] = np.clip(img, 0, 1).ravel().tolist()                 # row 0 = v 0 = bottom (blender order)
bim.filepath_raw = os.path.join(OUT, "sedan_headlight_crack_L.png"); bim.file_format = 'PNG'; bim.save()
mat = bpy.data.materials.new("HeadlightCrack"); mat.use_nodes = True
nt = mat.node_tree; bsdf = nt.nodes["Principled BSDF"]
tn = nt.nodes.new("ShaderNodeTexImage"); tn.image = bim
nt.links.new(tn.outputs["Color"], bsdf.inputs["Base Color"]); nt.links.new(tn.outputs["Alpha"], bsdf.inputs["Alpha"])
bsdf.inputs["Roughness"].default_value = 0.3
try:
    mat.blend_method = 'BLEND'
except Exception:
    pass
me.materials.append(mat)
export(os.path.join(OUT, "sedan_headlight_crack_L.glb"), [ob])
INFO["HeadlightCrack_L"] = dict(file="sedan_headlight_crack_L.glb", texture="sedan_headlight_crack_L.png",
                                note="thin shell 0.006 over the car-left end of the light bar (Shell lamp faces x < -1.55); "
                                     "SurfaceAppearance ColorMap = the png, AlphaMode = Transparency; show while the headlamp is "
                                     "broken, hide (Transparency 1 / parent nil) after Headlight_L is replaced; pivot = car origin",
                                tris=len(me.polygons))
print("CRACK", INFO["HeadlightCrack_L"]["tris"])
json.dump(INFO, open(os.path.join(OUT, "_mesh_info.json"), "w"), indent=1)
print("MESH DONE")
