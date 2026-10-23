"""Which raised-arm angle makes Ella's puff sleeve / forearm / hand clip the shawl, hair and braid least (wr-anim 10-23).
  blender -b --factory-startup -P tools/anim/ella_wave_scan.py            (reads nothing; prints WAVESCAN json lines)
Poses the right shoulder as rot_x(rx) @ rot_z(rz) and the elbow rot_x(el); counts vertices of the right sleeve / lower arm / hand
that sit inside the shawl / braid / hair meshes (BVH ray parity, as check_pose.py), and the shawl vertices inside the sleeve."""
import json, os, sys, math, itertools
HERE = os.path.dirname(os.path.abspath(__file__))
ELLA = os.path.abspath(os.path.join(HERE, "..", "..", "art", "3d", "ella_v2"))
sys.path.insert(0, os.path.join(ELLA, "scripts"))
import numpy as np
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree
import elib as E
import body_def as B

os.chdir(ELLA)
E.reset_scene()


def load(name):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(ELLA, name))
    ob = [o for o in set(bpy.context.scene.objects) - before if o.type == "MESH"][0]
    return ob, E.mesh_points_r(ob)


def tree(ob, P):
    return BVHTree.FromPolygons([Vector(tuple(p)) for p in P], [list(pl.vertices) for pl in ob.data.polygons])


def inside(bvh, p):
    votes = 0
    for d in ((0, 1, 0), (0.3, -1, 0.2), (1, 0.05, 0.1)):
        d = Vector(d).normalized()
        q, n = Vector(tuple(p)), 0
        for _ in range(40):
            loc, nrm, idx, dist = bvh.ray_cast(q, d)
            if loc is None:
                break
            n += 1
            q = loc + d * 1e-4
        votes += n % 2
    return votes >= 2


shawl_ob, shawl_P = load("ella_shawl.glb")
braid_ob, braid_P = load("ella_braid.glb")
hair_ob, hair_P = load("ella_hair.glb")
sleeve_ob, sleeve_P = load("ella_sleever.glb")
la_ob, la_P = load("body/RightLowerArm.glb")
hand_ob, hand_P = load("body/RightHand.glb")
ua_ob, ua_P = load("body/RightUpperArm.glb")
shawl_t, braid_t, hair_t = tree(shawl_ob, shawl_P), tree(braid_ob, braid_P), tree(hair_ob, hair_P)
sleeve_t = None


def pose_for(rx, ry, rz, el):
    B.POSES["scan"] = {"RightShoulder": B.rot_x(rx) @ B.rot_z(rz) if ry == 0 else B.rot_x(rx) @ B.rot_z(rz), "RightElbow": B.rot_x(el)}
    return B.pose_mats("scan")


def xf(P, M):
    return P @ M[:3, :3].T + M[:3, 3]


res = []
for rx, rz, el in itertools.product((-15, 0, 15, 30), (110, 120, 130, 140, 150, 160), (70, 90, 110)):
    PM = pose_for(rx, 0, rz, el)
    S = xf(sleeve_P, PM["RightUpperArm"])
    A = xf(ua_P, PM["RightUpperArm"])
    L = xf(la_P, PM["RightLowerArm"])
    H = xf(hand_P, PM["RightHand"])
    cnt = {
        "sleeve>shawl": sum(inside(shawl_t, v) for v in S) ,
        "arm>shawl": sum(inside(shawl_t, v) for v in np.vstack([A, L, H])),
        "arm>braid": sum(inside(braid_t, v) for v in np.vstack([L, H])),
        "arm>hair": sum(inside(hair_t, v) for v in np.vstack([L, H])),
    }
    hy = float(np.mean(H[:, 1]))
    res.append(dict(rx=rx, rz=rz, el=el, hand_y=round(hy, 2), tot=sum(cnt.values()), **cnt))
res.sort(key=lambda r: (r["tot"], -r["hand_y"]))
for r in res[:25]:
    print("WAVESCAN", json.dumps(r))
