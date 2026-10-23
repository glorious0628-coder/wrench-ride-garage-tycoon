# Smooth hard-surface parts for field props (pp-3d-props 10-20, user: "무조건 표면이 매끈해야 한다").
# slab(): a rounded-rectangle (or round, corner = half size) plate with rounded front/back edges, built from EVEN rings:
# each flat face has a support ring right where the edge rounding starts and one more inside it, so the flat face stays
# exactly flat and the shading only turns on the rounding (the bevelled cylinders / boxes of proc_lib gave patchy light
# on the sign's rims and base: fan caps + uneven bevel strips). Optional extra side rings make straight colour borders.
import bmesh, math
from mathutils import Vector, Matrix
import proc_lib as P


def _rrect(hw, hh, cr, k, support=True):
    """rounded rectangle, counter-clockwise, corner radius cr (cr = hw = hh -> a circle). support: two extra points on
    each straight side close to the corners, so a long flat side is not one face whose corner normals tint all of it
    (lamp g4: light bands down the middle block's flat sides)"""
    corners = []
    for sx, sy, a0 in ((1, 1, 0), (-1, 1, 90), (-1, -1, 180), (1, -1, 270)):
        cx, cy = sx * (hw - cr), sy * (hh - cr)
        corners.append([(cx + cr * math.cos(math.radians(a0 + 90 * j / k)), cy + cr * math.sin(math.radians(a0 + 90 * j / k)))
                        for j in range(k + 1)])
    pts = []
    for i, c in enumerate(corners):
        pts += c
        a, b = c[-1], corners[(i + 1) % 4][0]
        if support and math.hypot(b[0] - a[0], b[1] - a[1]) > 1e-6:   # no straight side on a circle / pill end
            pts += [(a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f) for f in (0.12, 0.88)]
    return pts


def slab(name, w, h, depth, corner, rad, center, axis='Y', k=8, n=3, side_rings=(), material=None, mat_fn=None,
         rad_back=None, scale_y=1.0, n_back=None):
    """w x h outline (in the plane across `axis`), `depth` along it, outline corner radius `corner`, edge rounding `rad`
    (n steps). side_rings: extra ring positions along the axis (from the back face, 0..depth) for colour borders.
    mat_fn(t_mid) -> material index per face strip by its axis position (t from the back face), optional."""
    hw, hh, t0, t1 = w / 2, h / 2, -depth / 2, depth / 2
    rb = rad if rad_back is None else rad_back      # rounding on the back (t0) side, e.g. a foot's small lower edge
    if rb + rad > depth:                            # both roundings must fit in the depth (lamp g8 lens: flipped rings)
        f = depth / (rb + rad) * 0.999; rb *= f; rad *= f
    rings = []   # (t, inset)
    sup = min(rb * 0.5, max(hw, hh) * 0.2)
    rings.append((t0, rb + sup))
    rings.append((t0, rb))
    nb = n if n_back is None else n_back           # fewer steps on a back side nobody looks at (floor, buried)
    for j in range(1, nb + 1):
        a = math.pi / 2 * j / nb
        rings.append((t0 + rb - rb * math.cos(a), rb - rb * math.sin(a)))
    for s in sorted(side_rings):
        if t0 + rb < t0 + s < t1 - rad:
            rings.append((t0 + s, 0.0))
    # the front rounding starts with its own inset-0 ring at t1 - rad (it was missing: the first step of every front
    # rounding was one long slanted face = the "45-degree chamfer" pp-3d-check saw on the lamp / sign / bench)
    for j in range(n, -1, -1):
        a = math.pi / 2 * j / n
        t = t1 - rad + rad * math.cos(a)
        if j == n and abs(t - rings[-1][0]) < 1e-6 and rings[-1][1] == 0.0:
            continue
        rings.append((t, rad - rad * math.sin(a)))
    rings.append((t1, rad + min(rad * 0.5, max(hw, hh) * 0.2)))
    bm = bmesh.new(); vr = []
    for t, d in rings:
        pts = _rrect(hw - d, hh - d, max(corner - d, min(hw, hh) * 0.02), k)
        vr.append([bm.verts.new((x, t, y * scale_y)) for x, y in pts])
    m = len(vr[0]); faces_t = []
    for (ta, _), (tb, _), r0, r1 in zip(rings[:-1], rings[1:], vr[:-1], vr[1:]):
        for j in range(m):
            f = bm.faces.new((r0[j], r1[j], r1[(j + 1) % m], r0[(j + 1) % m])); faces_t.append((f, (ta + tb) / 2 - t0))
    for ring, t in ((vr[0], t0), (vr[-1], t1)):
        c = bm.verts.new((0, t, 0))
        for j in range(m):
            f = bm.faces.new((ring[j], ring[(j + 1) % m], c)); faces_t.append((f, t - t0))
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    if mat_fn is not None:
        for f, tm in faces_t:
            f.material_index = mat_fn(tm)
    rot = {'Y': Matrix.Identity(4), 'Z': Matrix.Rotation(math.pi / 2, 4, 'X'), 'X': Matrix.Rotation(-math.pi / 2, 4, 'Z')}[axis]
    bmesh.ops.transform(bm, matrix=rot, verts=bm.verts)
    bmesh.ops.translate(bm, vec=Vector(center), verts=bm.verts)
    ob = P._new(name, bm)
    if material is not None:
        for mt in (material if isinstance(material, (list, tuple)) else [material]):
            ob.data.materials.append(mt)
    return ob


def rod(name, r, z0, z1, center_xy=(0, 0), segs=24, material=None):
    """a plain round pole between z0 and z1 (its ends are buried in other parts; closed so nothing is open)"""
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=True, segments=segs, radius1=r, radius2=r, depth=z1 - z0)
    bmesh.ops.translate(bm, vec=Vector((center_xy[0], center_xy[1], (z0 + z1) / 2)), verts=bm.verts)
    ob = P._new(name, bm)
    if material is not None:
        ob.data.materials.append(material)
    return ob
