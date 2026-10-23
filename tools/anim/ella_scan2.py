"""wr-anim 10-23: (a) sit: where do Ella's hands touch the seated skirt, (b) wave: how close does the raised hand / forearm get to hair / head.
  blender -b --factory-startup -P tools/anim/ella_scan2.py -- sit|wave"""
import json, os, sys, itertools
HERE = os.path.dirname(os.path.abspath(__file__))
ELLA = os.path.abspath(os.path.join(HERE, "..", "..", "art", "3d", "ella_v2"))
sys.path.insert(0, os.path.join(ELLA, "scripts"))
import numpy as np
import bpy
from mathutils import Vector
from mathutils.bvhtree import BVHTree
import elib as E
import body_def as B

mode = sys.argv[sys.argv.index("--") + 1]
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


def xf(P, M):
    return P @ M[:3, :3].T + M[:3, 3]


if mode == "sit":
    sk_ob, sk_P = load("ella_skirtsit.glb")
    sk_t = tree(sk_ob, sk_P)
    hand_ob, hand_P = load("body/RightHand.glb")
    la_ob, la_P = load("body/RightLowerArm.glb")
    res = []
    for sh, el, out in itertools.product((10, 18, 26, 34), (40, 52, 64, 76), (-30, -20, -10)):
        B.POSES["s"] = {"RightHip": B.rot_x(90), "LeftHip": B.rot_x(90), "RightKnee": B.rot_x(-90), "LeftKnee": B.rot_x(-90),
                        "RightShoulder": B.rot_x(sh) @ B.rot_z(out), "RightElbow": B.rot_x(el)}
        PM = B.pose_mats("s")
        H = xf(hand_P, PM["RightHand"])
        L = xf(la_P, PM["RightLowerArm"])
        V = np.vstack([H, L])
        n_in = sum(inside(sk_t, v) for v in V[::2])
        dmin = min(sk_t.find_nearest(Vector(tuple(h)))[3] for h in H[::2])
        res.append(dict(sh=sh, el=el, out=out, hand_in=int(n_in), hand_min_dist=round(float(dmin), 3),
                        hand_y=round(float(H[:, 1].mean()), 2), hand_x=round(float(H[:, 0].mean()), 2), hand_z=round(float(H[:, 2].mean()), 2)))
    res = [r for r in res if r["hand_in"] <= 2]
    res.sort(key=lambda r: (r["hand_min_dist"], abs(r["hand_x"])))
    for r in res[:14]:
        print("SCAN", json.dumps(r))
else:
    hair_ob, hair_P = load("ella_hair.glb")
    hair_t = tree(hair_ob, hair_P)
    shawl_ob, shawl_P = load("ella_shawl.glb")
    shawl_t = tree(shawl_ob, shawl_P)
    hand_ob, hand_P = load("body/RightHand.glb")
    la_ob, la_P = load("body/RightLowerArm.glb")
    for el in (20, 30, 40, 50, 60, 75):
        B.POSES["w"] = {"RightShoulder": B.rot_x(10) @ B.rot_z(135), "RightElbow": B.rot_x(el)}
        PM = B.pose_mats("w")
        H = xf(hand_P, PM["RightHand"]); L = xf(la_P, PM["RightLowerArm"])
        d = lambda t, V: min(t.find_nearest(Vector(tuple(v)))[3] for v in V[::2])
        ins = sum(inside(hair_t, v) for v in np.vstack([H, L])[::2])
        print("SCAN", json.dumps(dict(el=el, hair_inside=int(ins), hand_hair_dist=round(float(d(hair_t, H)), 3), arm_hair_dist=round(float(d(hair_t, L)), 3),
                                      hand_y=round(float(H[:, 1].mean()), 2), hand_x=round(float(H[:, 0].mean()), 2))))
