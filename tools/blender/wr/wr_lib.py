# Wrench & Ride 3D helpers (wr-3d, 10-21) on top of tools/blender/proc_lib.py (Parcel Panic "clean primitives" way).
# Build frame for car parts (car_spec: 1 BU = 1 stud): Blender +X = car right (outboard for a RIGHT wheel), +Y = car
# front, +Z = up. The glTF exporter turns this into Roblox +X right, +Y up, -Z front (car_spec front = -Z).
# Wheel parts are built around the wheel centre (origin), wheel axis = X.
# "clock" angles: seen from outside the right wheel (camera on +X), 0 = 12 o'clock, clockwise, 90 = car front.
import bpy, bmesh, math, os, sys
from mathutils import Vector, Matrix

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import proc_lib as P  # noqa: E402


def clock_dir(theta_deg):
    """unit vector in the wheel plane (Y = front, Z = up) for a clock angle (0 = up, 90 = front)"""
    t = math.radians(theta_deg)
    return Vector((0.0, math.sin(t), math.cos(t)))


def _finish_bm(name, bm, material=None, recalc=True):
    if recalc:
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    ob = P._new(name, bm)
    if material is not None:
        for m in (material if isinstance(material, (list, tuple)) else [material]):
            ob.data.materials.append(m)
    return ob


def revolve_x(name, loop, segs, material=None, closed=True, a0=0.0, center=(0, 0, 0), axis='X'):
    """revolve (r, h) profile points around an axis (default X, h along the axis). closed=True joins the last
    profile point back to the first (a ring / torus-like solid); r = 0 points become poles. Even rings -> even
    shading (no wavy highlight)."""
    bm = bmesh.new(); rings = []
    c = Vector(center)
    for r, h in loop:
        if r < 1e-7:
            rings.append([bm.verts.new(c + _ax(axis, h, 0, 0))])
        else:
            rings.append([bm.verts.new(c + _ax(axis, h, r * math.cos(a0 + 2 * math.pi * i / segs),
                                               r * math.sin(a0 + 2 * math.pi * i / segs))) for i in range(segs)])
    n = len(rings)
    pairs = [(i, i + 1) for i in range(n - 1)] + ([(n - 1, 0)] if closed else [])
    for ia, ib in pairs:
        a, b = rings[ia], rings[ib]
        if len(a) == 1 and len(b) == 1:
            continue
        for i in range(segs):
            j = (i + 1) % segs
            if len(a) == 1:
                bm.faces.new((a[0], b[i], b[j]))
            elif len(b) == 1:
                bm.faces.new((a[i], b[0], a[j]))
            else:
                bm.faces.new((a[i], b[i], b[j], a[j]))
    return _finish_bm(name, bm, material)


def _ax(axis, h, p, q):
    """point with h along `axis` and (p, q) in the plane across it"""
    if axis == 'X':
        return Vector((h, p, q))
    if axis == 'Y':
        return Vector((q, h, p))
    return Vector((p, q, h))


def loft(name, rings, cap0=True, cap1=True, material=None, closed_rings=True):
    """connect rings (lists of 3D points, same count) with quads; caps = fans to the ring centre"""
    bm = bmesh.new()
    vr = [[bm.verts.new(Vector(p)) for p in ring] for ring in rings]
    m = len(vr[0])
    for a, b in zip(vr[:-1], vr[1:]):
        for i in range(m if closed_rings else m - 1):
            j = (i + 1) % m
            bm.faces.new((a[i], b[i], b[j], a[j]))
    for ring, on in ((vr[0], cap0), (vr[-1], cap1)):
        if on:
            c = sum((v.co for v in ring), Vector()) / len(ring)
            cv = bm.verts.new(c)
            for i in range(m):
                bm.faces.new((ring[i], ring[(i + 1) % m], cv))
    return _finish_bm(name, bm, material)


def curve_plate(name, outlines, half_depth, bevel, res, matrix, material=None):
    """flat plate from 2D outlines (first = outside, others = holes) with chamfered / rounded edges (Blender curve
    fill). Curve local XY = the plate, local Z = thickness. The bevel GROWS the filled area by `bevel` at every
    border (outer bigger, holes smaller) and adds it to the thickness: half thickness = half_depth (bevel included).
    matrix: local -> build frame."""
    cu = bpy.data.curves.new(name + "_cu", 'CURVE'); cu.dimensions = '2D'; cu.fill_mode = 'BOTH'
    cu.extrude = max(half_depth - bevel, 1e-5); cu.bevel_depth = bevel; cu.bevel_resolution = res
    for pts in outlines:
        sp = cu.splines.new('POLY'); sp.points.add(len(pts) - 1)
        for i, (u, v) in enumerate(pts):
            sp.points[i].co = (u, v, 0, 1)
        sp.use_cyclic_u = True
    tmp = bpy.data.objects.new(name + "_tmp", cu); bpy.context.scene.collection.objects.link(tmp)
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(tmp.evaluated_get(dg))
    bpy.data.objects.remove(tmp)
    me.transform(matrix)
    bm = bmesh.new(); bm.from_mesh(me)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
    return _finish_bm(name, bm, material)


def circle_pts(cx, cy, r, n, a0=0.0):
    return [(cx + r * math.cos(a0 + 2 * math.pi * i / n), cy + r * math.sin(a0 + 2 * math.pi * i / n)) for i in range(n)]


def rrect_pts(hw, hh, cr, k=4, cx=0.0, cy=0.0):
    """rounded rectangle outline (counter-clockwise)"""
    pts = []
    for sx, sy, a0 in ((1, 1, 0), (-1, 1, 90), (-1, -1, 180), (1, -1, 270)):
        ccx, ccy = sx * (hw - cr), sy * (hh - cr)
        for j in range(k + 1):
            a = math.radians(a0 + 90 * j / k)
            pts.append((cx + ccx + cr * math.cos(a), cy + ccy + cr * math.sin(a)))
    return pts


def offset_outline(pts, d):
    """move every point of a closed CCW outline outward by d along the vertex normal (d < 0 = inset)"""
    n = len(pts); out = []
    for i in range(n):
        p0, p1, p2 = Vector(pts[i - 1]), Vector(pts[i]), Vector(pts[(i + 1) % n])
        e0 = (p1 - p0).normalized(); e1 = (p2 - p1).normalized()
        n0 = Vector((e0.y, -e0.x)); n1 = Vector((e1.y, -e1.x))
        nb = (n0 + n1); nb = nb.normalized() if nb.length > 1e-9 else n0
        k = 1.0 / max(nb.dot(n0), 0.35)
        q = p1 + nb * d * k
        out.append((q.x, q.y))
    return out


def outline_slab(name, pts, t0, t1, rad, n, matrix, material=None, rad_back=None, n_back=None, side_rings=(), support=True, cap='cdt'):
    """extrude a closed CCW 2D outline (local XY) from local z = t0 to t1 with rounded front (t1) / back (t0) edges
    made of EVEN inset rings (flat faces stay flat, shading only turns on the rounding; props_lib.slab idea but any
    outline). Caps = fans to the centroid (outline must be star-shaped from it). matrix: local -> build frame."""
    rb = rad if rad_back is None else rad_back; nb = n if n_back is None else n_back
    depth = t1 - t0
    if rb + rad > depth:
        f = depth / (rb + rad) * 0.999; rb *= f; rad *= f
    rings = []
    if support:
        rings.append((t0, -(rb + rb * 0.4)))
    for j in range(0, nb + 1):
        a = math.pi / 2 * j / nb
        rings.append((t0 + rb - rb * math.cos(a), -(rb - rb * math.sin(a))))
    for s in sorted(side_rings):
        if t0 + rb < s < t1 - rad:
            rings.append((s, 0.0))
    for j in range(n, -1, -1):
        a = math.pi / 2 * j / n
        t = t1 - rad + rad * math.cos(a)
        rings.append((t, -(rad - rad * math.sin(a))))
    if support:
        rings.append((t1, -(rad + rad * 0.4)))
    # drop exact duplicates (rb = 0)
    clean = []
    for t, d in rings:
        if clean and abs(clean[-1][0] - t) < 1e-9 and abs(clean[-1][1] - d) < 1e-9:
            continue
        clean.append((t, d))
    bm = bmesh.new(); vr = []
    for t, d in clean:
        ring = offset_outline(pts, d) if abs(d) > 1e-9 else pts
        vr.append([bm.verts.new(matrix @ Vector((x, y, t))) for x, y in ring])
    m = len(pts)
    for r0, r1 in zip(vr[:-1], vr[1:]):
        for j in range(m):
            bm.faces.new((r0[j], r1[j], r1[(j + 1) % m], r0[(j + 1) % m]))
    if cap == 'fan':
        cx = sum(p[0] for p in pts) / m; cy = sum(p[1] for p in pts) / m
        for ring, t in ((vr[0], t0), (vr[-1], t1)):
            c = bm.verts.new(matrix @ Vector((cx, cy, t)))
            for j in range(m):
                bm.faces.new((ring[j], ring[(j + 1) % m], c))
    else:   # constrained Delaunay on the cap outline: works for concave outlines (C-shapes)
        from mathutils.geometry import delaunay_2d_cdt
        for ring, (t, d) in ((vr[0], clean[0]), (vr[-1], clean[-1])):
            cp = offset_outline(pts, d) if abs(d) > 1e-9 else pts
            res = delaunay_2d_cdt([Vector(p) for p in cp], [(j, (j + 1) % m) for j in range(m)], [], 0, 1e-9, True)
            ov, of, orig = res[0], res[2], res[3]
            for f in of:
                ids = [orig[i][0] if orig[i] else -1 for i in f]
                if min(ids) < 0 or len(set(ids)) < 3:
                    continue
                q = [ov[i] for i in f]
                cen = ((q[0].x + q[1].x + q[2].x) / 3, (q[0].y + q[1].y + q[2].y) / 3)
                if not _inside2d(cen, cp):
                    continue
                try:
                    bm.faces.new([ring[i] for i in ids])
                except ValueError:
                    pass
    return _finish_bm(name, bm, material)


def _inside2d(p, poly):
    x, y = p; c = False; n = len(poly)
    for i in range(n):
        x0, y0 = poly[i]; x1, y1 = poly[(i + 1) % n]
        if (y0 > y) != (y1 > y) and x < x0 + (y - y0) * (x1 - x0) / (y1 - y0):
            c = not c
    return c


def round_corners(pts, rad, k=3):
    """round every corner of a closed 2D polygon with an arc of radius rad (clamped to 45 % of the shorter edge);
    rad may be a list (one radius per corner)"""
    n = len(pts); out = []
    rl = list(rad) if isinstance(rad, (list, tuple)) else [rad] * n
    for i in range(n):
        rad = rl[i]
        p0, p1, p2 = Vector(pts[i - 1]), Vector(pts[i]), Vector(pts[(i + 1) % n])
        d0 = (p0 - p1); d2 = (p2 - p1); l0, l2 = d0.length, d2.length
        d0.normalize(); d2.normalize()
        ang = math.acos(max(-1.0, min(1.0, d0.dot(d2))))
        if ang > math.radians(175) or rad <= 0:
            out.append((p1.x, p1.y)); continue
        t = rad / math.tan(ang / 2)
        t = min(t, 0.45 * l0, 0.45 * l2)
        rr = t * math.tan(ang / 2)
        a = p1 + d0 * t; b = p1 + d2 * t
        bis = (d0 + d2).normalized(); c = p1 + bis * (rr / math.sin(ang / 2))
        a0 = math.atan2(a.y - c.y, a.x - c.x); a1 = math.atan2(b.y - c.y, b.x - c.x)
        da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
        for j in range(k + 1):
            out.append((c.x + rr * math.cos(a0 + da * j / k), c.y + rr * math.sin(a0 + da * j / k)))
    return out


def densify(pts, step):
    """insert points on long edges of a closed outline"""
    out = []; n = len(pts)
    for i in range(n):
        p, q = Vector(pts[i]), Vector(pts[(i + 1) % n])
        m = max(1, int(math.ceil((q - p).length / step)))
        for j in range(m):
            r = p.lerp(q, j / m); out.append((r.x, r.y))
    return out


def frame(origin, ex, ey, ez):
    """4x4 matrix whose local X/Y/Z axes are ex/ey/ez at origin (build frame)"""
    ex, ey, ez = Vector(ex), Vector(ey), Vector(ez)
    return Matrix(((ex.x, ey.x, ez.x, origin[0]), (ex.y, ey.y, ez.y, origin[1]), (ex.z, ey.z, ez.z, origin[2]), (0, 0, 0, 1)))


def tube(name, pts, radius, around=10, material=None, cap=True):
    """round tube along a smooth 3D polyline (hose, valve stem), parallel-transport frames, flat end caps"""
    pts = [Vector(p) for p in pts]
    rads = radius if isinstance(radius, (list, tuple)) else [radius] * len(pts)
    t0 = (pts[1] - pts[0]).normalized()
    ref = Vector((0, 0, 1)) if abs(t0.z) < 0.9 else Vector((1, 0, 0))
    nrm = t0.cross(ref).normalized()
    rings = []
    prev_t = t0
    for i, p in enumerate(pts):
        if i == 0:
            t = t0
        elif i == len(pts) - 1:
            t = (pts[i] - pts[i - 1]).normalized()
        else:
            t = (pts[i + 1] - pts[i - 1]).normalized()
        # parallel transport the normal
        ax = prev_t.cross(t)
        if ax.length > 1e-8:
            ang = math.asin(min(1.0, ax.length))
            nrm = Matrix.Rotation(ang, 3, ax.normalized()) @ nrm
        prev_t = t
        b = t.cross(nrm).normalized(); nn = b.cross(t).normalized()
        rings.append([p + (nn * math.cos(2 * math.pi * k / around) + b * math.sin(2 * math.pi * k / around)) * rads[i]
                      for k in range(around)])
    return loft(name, rings, cap0=cap, cap1=cap, material=material)


def even_caps(ob, axis_vec, L, iters=10):
    """re-triangulate the flat cap faces (normal +-axis_vec) of a curve-filled plate into an even triangle mesh
    (edges <= L) so the plate can be bent smoothly afterwards (the curve fill makes long thin triangles)"""
    ax = Vector(axis_vec).normalized()
    bm = bmesh.new(); bm.from_mesh(ob.data)

    def caps():
        bm.normal_update()
        return [f for f in bm.faces if abs(f.normal.dot(ax)) > 0.999]
    for _ in range(iters):
        cf = set(caps())
        bmesh.ops.triangulate(bm, faces=list(cf))
        cf = set(caps())
        inner = [e for e in bm.edges if len(e.link_faces) == 2 and all(f in cf for f in e.link_faces)]
        bmesh.ops.beautify_fill(bm, faces=list(cf), edges=inner)
        cf = set(caps())
        long_ = [e for e in bm.edges if len(e.link_faces) == 2 and all(f in cf for f in e.link_faces) and e.calc_length() > L]
        if not long_:
            break
        bmesh.ops.subdivide_edges(bm, edges=long_, cuts=1, use_grid_fill=False)
    cf = set(caps())
    bmesh.ops.triangulate(bm, faces=list(cf))
    cf = set(caps())
    inner = [e for e in bm.edges if len(e.link_faces) == 2 and all(f in cf for f in e.link_faces)]
    bmesh.ops.beautify_fill(bm, faces=list(cf), edges=inner)
    bm.to_mesh(ob.data); bm.free()


def ring_caps(ob, side, ds, r_max=None, margin=0.5):
    """replace the flat cap faces (normal = side * X) of a plate with a constrained Delaunay fill whose inner points
    sit on concentric rings (radial step ds, ~ds apart around): regular radial rows, so a plate bent by a function of
    the radius shades smoothly. Boundary verts / edges are kept (they are shared with the chamfer)."""
    from mathutils.geometry import delaunay_2d_cdt
    bm = bmesh.new(); bm.from_mesh(ob.data); bm.normal_update()
    cap = [f for f in bm.faces if f.normal.x * side > 0.999]
    capset = set(cap)
    xcap = sum(f.calc_center_median().x for f in cap) / len(cap)
    bedges = [e for e in bm.edges if sum(1 for f in e.link_faces if f in capset) == 1]
    bverts = list({v for e in bedges for v in e.verts})
    idx = {v: i for i, v in enumerate(bverts)}
    segs = [((e.verts[0].co.y, e.verts[0].co.z), (e.verts[1].co.y, e.verts[1].co.z)) for e in bedges]

    def inside(p):   # even-odd test over the boundary edges
        y, z = p; c = False
        for (y0, z0), (y1, z1) in segs:
            if (z0 > z) != (z1 > z):
                yi = y0 + (z - z0) * (y1 - y0) / (z1 - z0)
                if yi > y:
                    c = not c
        return c

    def dist(p):
        y, z = p; best = 1e9
        for (y0, z0), (y1, z1) in segs:
            dy, dz = y1 - y0, z1 - z0; L2 = dy * dy + dz * dz
            t = max(0.0, min(1.0, ((y - y0) * dy + (z - z0) * dz) / L2)) if L2 > 0 else 0.0
            best = min(best, math.hypot(y - y0 - t * dy, z - z0 - t * dz))
        return best
    rmax = r_max or max(math.hypot(v.co.y, v.co.z) for v in bverts)
    pts = [(v.co.y, v.co.z) for v in bverts]
    r = ds
    while r < rmax:
        n = max(6, int(round(2 * math.pi * r / ds)))
        for i in range(n):
            a = 2 * math.pi * (i + 0.5 * (int(r / ds) % 2)) / n
            p = (r * math.sin(a), r * math.cos(a))
            if inside(p) and dist(p) > margin * ds:
                pts.append(p)
        r += ds
    cons = [(idx[e.verts[0]], idx[e.verts[1]]) for e in bedges]
    res = delaunay_2d_cdt([Vector(p) for p in pts], cons, [], 0, 1e-7, True)
    ov, oe, of, orig_v = res[0], res[1], res[2], res[3]
    bmesh.ops.delete(bm, geom=cap, context='FACES_ONLY')
    vmap = {}
    for i, co in enumerate(ov):
        src = [j for j in orig_v[i] if j < len(pts)]
        if src and src[0] < len(bverts):
            vmap[i] = bverts[src[0]]
        else:
            vmap[i] = bm.verts.new((xcap, co.x, co.y))
    made = 0
    for f in of:
        p = [ov[i] for i in f]
        cen = ((p[0].x + p[1].x + p[2].x) / 3, (p[0].y + p[1].y + p[2].y) / 3)
        if not inside(cen):
            continue
        vs = [vmap[i] for i in f]
        if len(set(vs)) < 3:
            continue
        try:
            nf = bm.faces.new(vs)
        except ValueError:
            continue
        nf.normal_update()
        if nf.normal.x * side < 0:
            nf.normal_flip()
        if cap:
            nf.material_index = cap[0].material_index if cap[0].is_valid else 0
        made += 1
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
    bm.to_mesh(ob.data); bm.free()
    return made


def fillet_window(th1, th2, hw, r_in, r_out, rho_in, rho_out, n_fil=4, n_line=6, n_in=4, n_out=8):
    """outline (u, v) = (front, up) of the opening between two spokes (clock angles th1 < th2), spokes = parallel
    bars of half width hw; inner end on the circle r_in, outer end on r_out, all four corners filleted"""
    def cd(t):
        return Vector((math.sin(math.radians(t)), math.cos(math.radians(t))))
    a1, n1 = cd(th1), cd(th1 + 90); a2, n2 = cd(th2), cd(th2 - 90)

    def centre(a, n, R, rho, inner):
        d = hw + rho; RR = R + rho if inner else R - rho
        return n * d + a * math.sqrt(RR * RR - d * d)

    def arc(c, rad, p, q, k):
        a0 = math.atan2(p.y - c.y, p.x - c.x); a1_ = math.atan2(q.y - c.y, q.x - c.x)
        da = (a1_ - a0 + math.pi) % (2 * math.pi) - math.pi
        return [c + Vector((math.cos(a0 + da * j / k), math.sin(a0 + da * j / k))) * rad for j in range(1, k)]

    def line(p, q, k):
        return [p.lerp(q, j / k) for j in range(1, k)]
    cA = centre(a1, n1, r_in, rho_in, True); cB = centre(a1, n1, r_out, rho_out, False)
    cC = centre(a2, n2, r_out, rho_out, False); cD = centre(a2, n2, r_in, rho_in, True)
    Ac, Al = cA * (r_in / cA.length), cA - n1 * rho_in
    Bl, Bc = cB - n1 * rho_out, cB * (r_out / cB.length)
    Cc, Cl = cC * (r_out / cC.length), cC - n2 * rho_out
    Dl, Dc = cD - n2 * rho_in, cD * (r_in / cD.length)
    O = Vector((0, 0))
    pts = [Ac] + arc(cA, rho_in, Ac, Al, n_fil) + [Al] + line(Al, Bl, n_line) + [Bl] + arc(cB, rho_out, Bl, Bc, n_fil) + [Bc]
    pts += arc(O, r_out, Bc, Cc, n_out) + [Cc] + arc(cC, rho_out, Cc, Cl, n_fil) + [Cl] + line(Cl, Dl, n_line) + [Dl]
    pts += arc(cD, rho_in, Dl, Dc, n_fil) + [Dc] + arc(O, r_in, Dc, Ac, n_in)
    return [(p.x, p.y) for p in pts]


def mark_sharp(ob, angle_deg):
    """mark edges sharper than angle_deg as sharp (kept by finish()'s shade smooth): flat curve-filled faces then
    shade perfectly flat instead of banding from the long fill triangles"""
    bm = bmesh.new(); bm.from_mesh(ob.data); bm.edges.ensure_lookup_table()
    sharp = []
    for e in bm.edges:
        if len(e.link_faces) == 2 and e.link_faces[0].normal.angle(e.link_faces[1].normal, 0) > math.radians(angle_deg):
            sharp.append(e.index)
    bm.free()
    attr = ob.data.attributes.get("sharp_edge") or ob.data.attributes.new("sharp_edge", 'BOOLEAN', 'EDGE')
    for i in sharp:
        attr.data[i].value = True
    return len(sharp)


def smoothstep(e0, e1, x):
    t = min(max((x - e0) / (e1 - e0), 0.0), 1.0)
    return t * t * (3 - 2 * t)


def join(name, obs):
    for o in bpy.context.scene.objects:
        o.select_set(o in obs)
    bpy.context.view_layer.objects.active = obs[0]
    if len(obs) > 1:
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active; ob.name = name
    return ob


def mirror_x(ob):
    """mirror a finished-shape object across the YZ plane (left-side copy) and flip faces so normals stay outward"""
    for v in ob.data.vertices:
        v.co.x = -v.co.x
    bm = bmesh.new(); bm.from_mesh(ob.data)
    bmesh.ops.reverse_faces(bm, faces=list(bm.faces))
    bm.to_mesh(ob.data); bm.free()


def translate(ob, d):
    ob.data.transform(Matrix.Translation(Vector(d)))


def clear_scene():
    for o in list(bpy.context.scene.objects):
        bpy.data.objects.remove(o, do_unlink=True)


def to_roblox(v):
    """build-frame vector (Blender) -> Roblox part space (x right, y up, -z front)"""
    return [round(v[0], 4), round(v[2], 4), round(-v[1], 4)]


# ---------------- LOD helpers (wr-3d 10-21 Detail / Lite) ----------------
def revolve_x_var(name, loop, segs, material=None, closed=True, center=(0, 0, 0), a0=0.0, recalc=True):
    """revolve_x with a segment count PER profile point (visible outer rings 64, hidden inner rings 32 ...).
    Neighbouring counts must be equal or one a multiple of the other; rings are stitched with fans."""
    bm = bmesh.new(); rings = []
    c = Vector(center)
    for (r, h), n in zip(loop, segs):
        if r < 1e-7:
            rings.append([bm.verts.new(c + Vector((h, 0, 0)))])
        else:
            rings.append([bm.verts.new(c + Vector((h, r * math.cos(a0 + 2 * math.pi * i / n), r * math.sin(a0 + 2 * math.pi * i / n))))
                          for i in range(n)])
    N = len(rings)
    pairs = [(i, i + 1) for i in range(N - 1)] + ([(N - 1, 0)] if closed else [])
    for ia, ib in pairs:
        A, Bv = rings[ia], rings[ib]
        na, nb = len(A), len(Bv)
        if na == 1 and nb == 1:
            continue
        if na == 1 or nb == 1:
            pole, ring = (A[0], Bv) if na == 1 else (Bv[0], A)
            for i in range(len(ring)):
                bm.faces.new((pole, ring[i], ring[(i + 1) % len(ring)]))
            continue
        if na == nb:
            for i in range(na):
                j = (i + 1) % na
                bm.faces.new((A[i], Bv[i], Bv[j], A[j]))
            continue
        fine, coarse = (A, Bv) if na > nb else (Bv, A)
        rev = na > nb          # keep the same winding as the quads (A[i], B[i], B[j], A[j])
        k = len(fine) // len(coarse)
        for j in range(len(coarse)):
            c0, c1 = coarse[j], coarse[(j + 1) % len(coarse)]
            for i in range(k):
                f0, f1 = fine[(k * j + i) % len(fine)], fine[(k * j + i + 1) % len(fine)]
                t = (f0, f1, c0 if i < k // 2 else c1)
                bm.faces.new(t[::-1] if rev else t)
            t = (fine[(k * j + k // 2) % len(fine)], c1, c0)
            bm.faces.new(t[::-1] if rev else t)
    return _finish_bm(name, bm, material, recalc=recalc)


def _ccw(loop):
    a = sum(loop[i][0] * loop[(i + 1) % len(loop)][1] - loop[(i + 1) % len(loop)][0] * loop[i][1] for i in range(len(loop)))
    return loop if a > 0 else loop[::-1]


def cdt_cap(bm, loops_verts, loops_2d, x, side, interior=(), uv_of=None):
    """fill the region between 2D loops (even-odd) at axis position x with a constrained Delaunay triangulation.
    loops_verts: BMVert lists matching loops_2d; interior: extra 2D points inside; side: +1 face +X, -1 face -X.
    2D (u, v) = build (y, z)."""
    from mathutils.geometry import delaunay_2d_cdt
    pts = []; vlist = []; cons = []
    for lv, l2 in zip(loops_verts, loops_2d):
        s = len(pts)
        for v, p in zip(lv, l2):
            pts.append(Vector(p)); vlist.append(v)
        n = len(l2)
        cons += [(s + i, s + (i + 1) % n) for i in range(n)]
    nb = len(pts)
    for p in interior:
        pts.append(Vector(p)); vlist.append(None)
    res = delaunay_2d_cdt(pts, cons, [], 0, 1e-9, True)
    ov, of, orig = res[0], res[2], res[3]
    segs = []
    for l2 in loops_2d:
        segs += [(l2[i], l2[(i + 1) % len(l2)]) for i in range(len(l2))]

    def inside(p):
        y, z = p; c = False
        for (y0, z0), (y1, z1) in segs:
            if (z0 > z) != (z1 > z) and y < y0 + (z - z0) * (y1 - y0) / (z1 - z0):
                c = not c
        return c
    vmap = {}
    for i, co in enumerate(ov):
        src = orig[i][0] if orig[i] else None
        if src is not None and vlist[src] is not None:
            vmap[i] = vlist[src]
        else:
            vmap[i] = bm.verts.new((x, co.x, co.y))
    made = 0
    for f in of:
        q = [ov[i] for i in f]
        if not inside(((q[0].x + q[1].x + q[2].x) / 3, (q[0].y + q[1].y + q[2].y) / 3)):
            continue
        vs = [vmap[i] for i in f]
        if len(set(vs)) < 3:
            continue
        try:
            nf = bm.faces.new(vs)
        except ValueError:
            continue
        nf.normal_update()
        if nf.normal.x * side < 0:
            nf.normal_flip()
        made += 1
    return made


def ring_points(loops_2d, ds, rmax, margin=0.5):
    """interior points on concentric rings (radial step ds) inside the even-odd region of loops_2d"""
    segs = []
    for l2 in loops_2d:
        segs += [(l2[i], l2[(i + 1) % len(l2)]) for i in range(len(l2))]

    def inside(p):
        y, z = p; c = False
        for (y0, z0), (y1, z1) in segs:
            if (z0 > z) != (z1 > z) and y < y0 + (z - z0) * (y1 - y0) / (z1 - z0):
                c = not c
        return c

    def dist(p):
        y, z = p; best = 1e9
        for (y0, z0), (y1, z1) in segs:
            dy, dz = y1 - y0, z1 - z0; L2 = dy * dy + dz * dz
            t = max(0.0, min(1.0, ((y - y0) * dy + (z - z0) * dz) / L2)) if L2 > 0 else 0.0
            best = min(best, math.hypot(y - y0 - t * dy, z - z0 - t * dz))
        return best
    out = []; r = ds; k = 0
    while r < rmax:
        n = max(6, int(round(2 * math.pi * r / ds)))
        for i in range(n):
            a = 2 * math.pi * (i + 0.5 * (k % 2)) / n
            p = (r * math.sin(a), r * math.cos(a))
            if inside(p) and dist(p) > margin * ds:
                out.append(p)
        r += ds; k += 1
    return out


def plate2d(name, outer, holes, x0, x1, chamfer, material=None, outer_chamfer=True, front_ds=None, back_ds=None, rmax=1.0,
            hole_chamfer=None, back_chamfer=0.0):
    """flat plate across the X axis between x0 (back) and x1 (front) from a 2D outer loop + hole loops ((y, z)).
    Side walls + ONE front chamfer strip (45 deg, crisp), no back chamfer (cheaper than the curve bevel).
    Caps = constrained Delaunay, optional interior ring points (front_ds / back_ds) so the plate can be bent."""
    hc = hole_chamfer if hole_chamfer is not None else [True] * len(holes)
    loops = [(_ccw(outer), True, outer_chamfer)] + [(_ccw(h), False, c) for h, c in zip(holes, hc)]
    bm = bmesh.new()
    back_v, back_2d, front_v, front_2d = [], [], [], []
    for loop, is_outer, want in loops:
        n = len(loop)
        do_ch = chamfer > 0 and want
        ins = offset_outline(loop, -chamfer if is_outer else chamfer) if do_ch else loop
        bch = back_chamfer if (back_chamfer > 0 and want) else 0.0
        bins = offset_outline(loop, -bch if is_outer else bch) if bch else loop
        vbb = [bm.verts.new((x0, p[0], p[1])) for p in bins]            # back cap ring (inset when chamfered)
        vb = [bm.verts.new((x0 + bch, p[0], p[1])) for p in loop] if bch else vbb
        vm = [bm.verts.new((x1 - (chamfer if do_ch else 0), p[0], p[1])) for p in loop]
        vf = [bm.verts.new((x1, p[0], p[1])) for p in ins] if do_ch else None
        for i in range(n):
            j = (i + 1) % n
            if bch:
                bm.faces.new((vbb[i], vbb[j], vb[j], vb[i]))
            bm.faces.new((vb[i], vb[j], vm[j], vm[i]))
            if do_ch:
                bm.faces.new((vm[i], vm[j], vf[j], vf[i]))
        back_v.append(vbb); back_2d.append(bins)
        front_v.append(vf if do_ch else vm); front_2d.append(ins)
    fi = ring_points(front_2d, front_ds, rmax) if front_ds else []
    bi = ring_points(back_2d, back_ds, rmax) if back_ds else []
    cdt_cap(bm, front_v, front_2d, x1, 1, fi)
    cdt_cap(bm, back_v, back_2d, x0, -1, bi)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    return _finish_bm(name, bm, material, recalc=False)


def orient_by(ob, test, want=1.0):
    """flip every face of an open shell if faces picked by test(centre) point against `want` * their expected side;
    test(centre, normal) -> +1 / -1 / 0 vote"""
    vote = sum(test(Vector(p.center), Vector(p.normal)) for p in ob.data.polygons)
    if vote * want < 0:
        bm = bmesh.new(); bm.from_mesh(ob.data); bmesh.ops.reverse_faces(bm, faces=list(bm.faces)); bm.to_mesh(ob.data); bm.free()
        return True
    return False


def revolve_arc(name, loop, segs, a0, a1, material=None, center=(0, 0, 0)):
    """revolve a closed (r, h) profile around X over the angle range a0..a1 (radians, 0 = +Y) with flat end caps"""
    bm = bmesh.new(); c = Vector(center); rings = []
    for i in range(segs + 1):
        a = a0 + (a1 - a0) * i / segs
        rings.append([bm.verts.new(c + Vector((h, r * math.cos(a), r * math.sin(a)))) for r, h in loop])
    n = len(loop)
    for A, B in zip(rings[:-1], rings[1:]):
        for k in range(n):
            bm.faces.new((A[k], A[(k + 1) % n], B[(k + 1) % n], B[k]))
    for ring in (rings[0], rings[-1]):
        bm.faces.new(ring)
    bmesh.ops.triangulate(bm, faces=[f for f in bm.faces if len(f.verts) > 4])
    return _finish_bm(name, bm, material)


def strip(name, pts, width, thick, side, material=None):
    """flat bent strip (spring tab) along a 3D polyline: rectangle width x thick, `side` = direction of the width"""
    pts = [Vector(p) for p in pts]; side = Vector(side).normalized(); rings = []
    for i, p in enumerate(pts):
        t = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
        w = (side - t * side.dot(t)).normalized(); nn = t.cross(w).normalized()
        rings.append([p + w * sx * width / 2 + nn * sy * thick / 2 for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))])
    return loft(name, rings, material=material)
