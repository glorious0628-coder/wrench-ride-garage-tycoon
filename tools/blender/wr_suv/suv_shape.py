# Crossover SUV body outer surface as a smooth lofted grid (wr-3d-suv, 10-21). Copied from the sedan's
# tools/blender/wr_body/body_shape.py (same ring / row structure) with the SUV numbers.
# Pure numpy. Car coords = car_spec / Roblox local: x = right (+), Y = up, s = Roblox Z (front -8.15, rear +8.45).
# 1 unit = 1 stud. Origin = ground between the axles.
# half ring H[0..29]: 0 = bottom centre, 6 = bottom corner (45 deg), 12..14 = shoulder crease, 18 = beltline / hood seam /
# window base, 21 = window (DLO) top, 23 = roof edge, 25 = roof inner (A / D pillar inner edge), 29 = top centre.
# Numbers: docs/specs/suv_spec.md v0.1 (16.6 x 7.7 x 6.6 (rails) / roof 6.4, wheelbase 9.7, axles +-4.85, hood hinge
# (0, 4.65, -3.6), belt 4.4..4.7, liftgate hinge (0, 6.35, +7.9), rear glass base ~4.7, rear bumper top ~2.9) +
# the 6-view concept (side / front / back / bottom cells stretched to the spec box; top cell = layout only).
import math
import numpy as np

S_FRONT, S_REAR = -8.12, 8.42      # + 0.03 cap bulge = -8.15 .. 8.45 (16.6)
NB, NS_, NT = 6, 17, 6
NH = NB + NS_ + NT + 1          # 30 points per half ring
ROW = dict(corner=NB, crease0=NB + 6, crease1=NB + 8, belt=NB + 12, dlo=NB + 15, roofedge=NB + 17, roofin=NB + 19, top=NH - 1)


def pchip(pts):
    """monotone cubic through (x, y) points -> f(x) (no overshoot: flat stays flat)"""
    xs = np.array([p[0] for p in pts], float); ys = np.array([p[1] for p in pts], float)
    h = np.diff(xs); d = np.diff(ys) / h; n = len(xs); m = np.zeros(n)
    for k in range(1, n - 1):
        if d[k - 1] * d[k] <= 0:
            m[k] = 0.0
        else:
            w1 = 2 * h[k] + h[k - 1]; w2 = h[k] + 2 * h[k - 1]
            m[k] = (w1 + w2) / (w1 / d[k - 1] + w2 / d[k])
    m[0] = d[0]; m[-1] = d[-1]

    def f(x):
        x = min(max(x, xs[0]), xs[-1]); k = int(min(max(np.searchsorted(xs, x) - 1, 0), n - 2))
        t = (x - xs[k]) / h[k]
        return float((2 * t ** 3 - 3 * t ** 2 + 1) * ys[k] + (t ** 3 - 2 * t ** 2 + t) * h[k] * m[k]
                     + (-2 * t ** 3 + 3 * t ** 2) * ys[k + 1] + (t ** 3 - t ** 2) * h[k] * m[k + 1])
    return f


def smoothstep(a, b, x):
    t = min(max((x - a) / (b - a), 0.0), 1.0)
    return t * t * (3 - 2 * t)


# ------------------------------------------------------------------------------------------------ SUV numbers ------
SPEC_SUV = dict(
    name="suv",
    # centreline top: high flat hood (front edge ~3.95 before the nose rounding, 4.70 at the windshield base), windshield
    # ~30 deg, near-flat roof 6.40 to the liftgate hinge (Z +7.9, Y 6.35), then rear glass nearly upright (~13 deg lean)
    # down to its base ~4.85 at Z +8.37 (spec 'rear glass base ~4.7', 'liftgate almost upright').
    top_hood=[(-8.15, 3.86), (-7.9, 3.95), (-7.5, 4.06), (-7.0, 4.19), (-6.4, 4.32), (-5.6, 4.45), (-5.0, 4.53),
              (-4.5, 4.60), (-4.05, 4.65)],
    top_cabin=[(-4.05, 4.65), (-3.0, 5.17), (-2.0, 5.64), (-1.2, 6.00), (-0.65, 6.21), (-0.25, 6.33), (0.15, 6.38), (0.6, 6.40), (2.5, 6.40), (4.5, 6.39), (6.0, 6.38), (7.0, 6.37), (7.6, 6.355),
               (7.9, 6.33), (8.00, 6.21), (8.08, 5.94), (8.17, 5.48), (8.25, 5.07), (8.30, 4.90), (8.37, 4.72),
               (8.45, 4.56)],
    top_deck=[(8.30, 4.90), (8.45, 4.56)],
    deck_merge=True,
    # beltline = hood / fender seam in front, window base along the cabin (4.4 front door -> 4.7 at the quarter glass),
    # wraps down round the rear corner into the tail lamps
    belt=[(-8.15, 3.64), (-7.8, 3.88), (-7.4, 4.03), (-6.5, 4.21), (-5.5, 4.32), (-4.6, 4.39), (-4.05, 4.42), (-3.55, 4.44),
          (-3.0, 4.43), (-2.0, 4.42), (-1.0, 4.43), (0.4, 4.46), (2.0, 4.52), (3.6, 4.58), (5.0, 4.64), (6.5, 4.68),
          (7.5, 4.70), (8.0, 4.62), (8.25, 4.46), (8.45, 4.22)],
    # shoulder crease through the door handles (concept: headlamp -> handles -> tail lamp, ~0.7 under the belt)
    crease=[(-8.15, 3.42), (-7.6, 3.53), (-6.5, 3.65), (-5.0, 3.72), (-3.0, 3.75), (0.0, 3.78), (3.0, 3.83),
            (5.0, 3.88), (6.5, 3.92), (7.5, 3.92), (8.45, 3.82)],
    gh=(-4.05, -3.45, 8.28, 8.42),        # greenhouse -> smooth deck below the rear glass base (no pinch at the D-pillar foot)
    ybot=[(-8.15, 0.90), (-7.3, 0.89), (-6.6, 0.86), (-6.0, 0.80), (6.0, 0.80), (6.6, 0.95), (7.3, 1.06), (8.45, 1.12)],
    width_core=3.79, width_hip=0.0,       # body side 3.79; the black arch / sill cladding stands 0.06 proud -> 3.85
    # end rounding: (length a, size b) ellipse quadrants. Front plan from the bottom / top cells (corner -> ~2.4 wide
    # at the hood edge), upright nose (top 1.1 / bottom 0.9 roll-off, concept side cell). Rear: the lower body rounds
    # more in plan than the shoulder / greenhouse (plan_up), so the rear glass stays wide.
    end_front=dict(plan=(1.7, 1.8), top=(0.5, 1.1), bot=(0.6, 0.55)),
    end_rear=dict(plan=(1.6, 1.55), plan_up=(1.3, 1.1), top=(0.04, 0.0), bot=(1.3, 0.55)),
    shelf=0.52,                           # shoulder: crease -> beltline step in (plan)
    tumble=0.45,                          # side glass lean (front view: 3.0 at Y 5.0 -> 2.6 at 5.86)
    crown_roof=0.20, dlo_gap=0.32,        # roof edge 0.2 under the centre; window top ~0.3 under the roof edge
    undercut=0.30, crease_in=0.06, crease_handle=0.30,
    tight=[(-4.45, -3.3, 0.15), (7.55, 8.45, 0.045), (-2.6, 7.4, 0.40)],
    hood_crown_min=0.10,
    shear=None,
)
SPEC_A = dict(SPEC_SUV, name="A_spec")

# B = concept rear: same loft, then the upper rear is leaned forward by a smooth shear (s' = s - k(Y) w(s)): roof end /
# liftgate hinge ~Z 6.9 (spec 7.9), rear glass ~35 deg, lower liftgate leaning into the tail lamps (concept side cell);
# roof drops ~0.12 toward the rear like the concept. Below Y ~2.8 (bumper, arches) nothing moves.
SPEC_B = dict(SPEC_SUV, name="B_concept")
SPEC_B.update(
    top_cabin=[(-4.05, 4.65), (-3.0, 5.17), (-2.0, 5.64), (-1.2, 6.00), (-0.65, 6.21), (-0.25, 6.33), (0.15, 6.38), (0.6, 6.40), (2.5, 6.40), (4.5, 6.35), (6.0, 6.27), (7.0, 6.20), (7.6, 6.16),
               (7.9, 6.13), (8.00, 6.02), (8.08, 5.77), (8.17, 5.35), (8.25, 4.99), (8.30, 4.84), (8.37, 4.67),
               (8.45, 4.52)],
    shear=dict(k=0.33, Y0=3.3, blend=0.4, k2=0.25, Y1=5.2, blend2=0.4, s0=4.9, s1=7.4),
)


def _soft_ramp(t, b):
    """C1 ramp: 0 for t < -b, t for t > b, quadratic between"""
    if t <= -b:
        return 0.0
    if t >= b:
        return t
    return (t + b) ** 2 / (4 * b)


def shear_ds(P, s, Y):
    sh = P.get("shear")
    if not sh:
        return 0.0
    k = sh["k"] * _soft_ramp(Y - sh["Y0"], sh["blend"]) + sh.get("k2", 0.0) * _soft_ramp(Y - sh.get("Y1", 9.0), sh.get("blend2", 0.4))
    return -k * smoothstep(sh["s0"], sh["s1"], s)


class Shape:
    def __init__(self, P):
        self.P = P
        self.f_top_hood = pchip(P["top_hood"]); self.f_top_cabin = pchip(P["top_cabin"]); self.f_top_deck = pchip(P["top_deck"])
        self.f_belt = pchip(P["belt"]); self.f_crease = pchip(P["crease"]); self.f_ybot = pchip(P["ybot"])
        self.s_ws = P["top_cabin"][0][0]; self.s_rg = P["top_deck"][0][0]

    def top_full(self, s):
        if s <= self.s_ws:
            return self.f_top_hood(s)
        if s <= self.s_rg or self.P.get("deck_merge"):
            return self.f_top_cabin(s)
        return self.f_top_deck(s)

    def width_full(self, s):
        P = self.P
        return P["width_core"] + P["width_hip"] * (math.exp(-((s + 4.85) / 1.6) ** 2) + math.exp(-((s - 4.85) / 1.6) ** 2))

    def gfac(self, s):
        a, b, c, d = self.P["gh"]
        return smoothstep(a, b, s) * (1 - smoothstep(c, d, s))

    @staticmethod
    def _ell(d, ab):
        a, b = ab
        if d >= a:
            return 0.0
        t = 1 - max(d, 0.0) / a
        return b * (1 - math.sqrt(max(0.0, 1 - t * t)))

    def _end(self, s):
        P = self.P
        if s < 0:
            d = s - S_FRONT; e = P["end_front"]
        else:
            d = S_REAR - s; e = P["end_rear"]
        out = {k: self._ell(d, e[k]) for k in ("plan", "top", "bot")}
        out["plan_up"] = self._ell(d, e.get("plan_up", e["plan"]))
        return out

    def outline(self, s):
        """(W, Ybot, Ytop) after the end rounding + the full ones"""
        e = self._end(s)
        Wf, Bf, Tf = self.width_full(s), self.f_ybot(s), self.top_full(s)
        return Wf - e["plan"], Bf + e["bot"], Tf - e["top"], Wf, Bf, Tf

    def half_section(self, s):
        P = self.P
        W, Yb, Yt = self.width_full(s), self.f_ybot(s), self.top_full(s)
        Ybl, Ycr = self.f_belt(s), self.f_crease(s)
        Ycr = min(Ycr, Ybl - 0.08)
        g = self.gfac(s)
        fade = 1.0
        if s < -7.0:
            fade = 0.45 + 0.55 * smoothstep(S_FRONT, -7.0, s)
        if s > 7.9:
            fade = 0.45 + 0.55 * (1 - smoothstep(7.9, S_REAR, s))
        shelf = P["shelf"] * fade
        x_bl = W - 0.035 - shelf
        V = lambda x, y: np.array([x, y], float)
        nrm = lambda v: v / np.linalg.norm(v)
        rb = 0.30; tuck = 0.07
        Pb = V(W - tuck - rb, Yb)
        A1 = V(W - tuck - rb + rb * math.sin(math.radians(45)), Yb + rb - rb * math.cos(math.radians(45)))
        Ps = V(W - tuck, Yb + rb)
        Ym = 0.5 * (Yb + rb + Ycr - 0.05)
        A2 = V(W, Ym)
        C = V(W - 0.005, Ycr)
        up_in = nrm(V(P.get("undercut", 0.10), 1.0))
        B = V(x_bl, Ybl)
        sh_dir = nrm(B - C)
        A3 = C - up_in * P.get("crease_in", 0.035)
        A4 = C + sh_dir * 0.04
        A5 = B - sh_dir * 0.05
        pdeck = 2.4
        crown_deck = max(Yt - Ybl, P.get("hood_crown_min", 0.02))
        Ytd = max(Yt, Ybl + P.get("hood_crown_min", 0.02))
        deck_y = lambda x: Ytd - crown_deck * (abs(x) / x_bl) ** pdeck
        deck_dir = nrm(V(-1.0, crown_deck * pdeck / x_bl))
        pieces_deck = None; pieces_gh = None
        if g < 1.0:
            A6 = V(x_bl - 0.05, deck_y(x_bl - 0.05))
            xs = [x_bl - 0.05, x_bl - 0.14, x_bl - 0.24, x_bl - 0.45, 0.0]
            pieces_deck = dict(A5=A5, A6=A6, belt_out=deck_dir,
                               up=[("fn", (deck_y, xs[0], xs[1]), 3), ("fn", (deck_y, xs[1], xs[2]), 2),
                                   ("fn", (deck_y, xs[2], xs[3]), 2), ("fnc", (deck_y, xs[3], 0.0), NT - 2)])
        if g > 0.0:
            Yrail_c = self.top_full(s)
            Hro = Yrail_c - P["crown_roof"]
            Ygb = Ybl + 0.02
            Hdlo = max(Hro - P.get("dlo_gap", 0.18), Ygb + 0.05)
            Hro = max(Hro, Hdlo + 0.06)
            x_gb = x_bl - 0.05
            x_dlo = x_gb - (Hdlo - Ygb) * P["tumble"]
            x_ro = x_dlo - (Hro - Hdlo) * 0.55 - 0.02
            x_ri = x_ro - 0.30
            Hri = min(Hro + 0.07, Yt - 0.02)
            Ytc = max(Yt, Hri + 0.02)
            pr = 2.2
            roof_y = lambda x: Ytc - (Ytc - Hri) * (abs(x) / x_ri) ** pr
            roof_dir = nrm(V(-1.0, (Ytc - Hri) * pr / x_ri))
            A6 = V(x_gb, Ygb)
            A7 = V(x_dlo, Hdlo)
            gdir = nrm(A7 - A6)
            A9 = V(x_ri, Hri)
            L = np.linalg.norm(A9 - A7)
            c0, c1, c2, c3 = A7, A7 + gdir * L * 0.55, A9 - roof_dir * L * 0.45, A9
            pieces_gh = dict(A5=A5, A6=A6, belt_out=gdir,
                             up=[("line", (A6, A7, 0.012), 3), ("bez_half", (c0, c1, c2, c3, 0), 2),
                                 ("bez_half", (c0, c1, c2, c3, 1), 2), ("fnc", (roof_y, x_ri, 0.0), NT - 2)])
        lower = dict(Pb=Pb, A1=A1, Ps=Ps, A2=A2, A3=A3, A4=A4, C=C, up_in=up_in, sh_dir=sh_dir, W=W, Yb=Yb, rb=rb, tuck=tuck)
        return lower, pieces_deck, pieces_gh, g


def _bez(p0, p1, p2, p3, t):
    t = np.asarray(t)[:, None]
    return (1 - t) ** 3 * p0 + 3 * (1 - t) ** 2 * t * p1 + 3 * (1 - t) * t ** 2 * p2 + t ** 3 * p3


def _resample(dense, n, bias=None):
    d = np.r_[0, np.cumsum(np.linalg.norm(np.diff(dense, axis=0), axis=1))]
    u = np.linspace(0, 1, n + 1)
    if bias == "start":
        u = 1 - np.cos(u * math.pi / 2)
    if bias == "end":
        u = np.sin(u * math.pi / 2)
    tgt = u * d[-1]
    return np.stack([np.interp(tgt, d, dense[:, 0]), np.interp(tgt, d, dense[:, 1])], 1)


def _piece(kind, args, n):
    if kind == "line":
        a, b, bulge = args
        t = np.linspace(0, 1, 40)
        p = a[None] + (b - a)[None] * t[:, None]
        nrm_ = np.array([(b - a)[1], -(b - a)[0]]); nrm_ = nrm_ / np.linalg.norm(nrm_)
        p = p + nrm_[None] * (bulge * 4 * t * (1 - t))[:, None]
        return _resample(p, n)
    if kind == "bez":
        p0, p1, p2, p3 = args
        return _resample(_bez(p0, p1, p2, p3, np.linspace(0, 1, 60)), n)
    if kind == "bez_half":
        p0, p1, p2, p3, half = args
        t = np.linspace(0, 0.5, 40) if half == 0 else np.linspace(0.5, 1, 40)
        return _resample(_bez(p0, p1, p2, p3, t), n)
    if kind in ("fn", "fnc"):
        f, x0, x1 = args
        xs = np.linspace(x0, x1, 80)
        p = np.stack([xs, [f(x) for x in xs]], 1)
        return _resample(p, n, bias="start" if kind == "fnc" else None)
    if kind == "arc":
        a, b, r, c = args
        a0 = math.atan2(a[1] - c[1], a[0] - c[0]); a1 = math.atan2(b[1] - c[1], b[0] - c[0])
        t = np.linspace(a0, a1, 30)
        return _resample(np.stack([c[0] + r * np.cos(t), c[1] + r * np.sin(t)], 1), n)
    raise ValueError(kind)


def sample_half(shape, s):
    lower, pdk, pgh, g = shape.half_section(s)
    W, Yb = lower["W"], lower["Yb"]
    pts = []
    bot = _resample(np.array([[0.0, Yb], lower["Pb"]]), NB - 2)
    pts += list(bot)
    c = np.array([W - lower["tuck"] - lower["rb"], Yb + lower["rb"]])
    pts += list(_piece("arc", (lower["Pb"], lower["A1"], lower["rb"], c), 2)[1:])
    pts += list(_piece("arc", (lower["A1"], lower["Ps"], lower["rb"], c), 1)[1:])
    A2, A3, A4 = lower["A2"], lower["A3"], lower["A4"]
    Ps = lower["Ps"]
    L = np.linalg.norm(A2 - Ps)
    pts += list(_piece("bez", (Ps, Ps + np.array([0.012, 1.0]) * L * 0.4, A2 - np.array([0, 1.0]) * L * 0.4, A2), 2)[1:])
    L = np.linalg.norm(A3 - A2)
    hA3 = shape.P.get("crease_handle", 0.4)
    pts += list(_piece("bez", (A2, A2 + np.array([0, 1.0]) * L * 0.4, A3 - lower["up_in"] * L * hA3, A3), 3)[1:])
    pts += list(_piece("bez", (A3, A3 + lower["up_in"] * 0.02, A4 - lower["sh_dir"] * 0.02, A4), 2)[1:])

    def upper(pc):
        A5, A6 = pc["A5"], pc["A6"]
        L = np.linalg.norm(A5 - A4)
        sh = lower["sh_dir"]
        out = np.array([sh[1], -sh[0]])
        seg = list(_piece("bez", (A4, A4 + sh * L * 0.35 + out * 0.025, A5 - sh * L * 0.35 + out * 0.025, A5), 3)[1:])
        Lb = np.linalg.norm(A6 - A5)
        seg += list(_piece("bez", (A5, A5 + sh * Lb * 0.45, A6 - pc["belt_out"] * Lb * 0.45, A6), 1)[1:])
        for kind, args, n in pc["up"]:
            seg += list(_piece(kind, args, n)[1:])
        return np.array(seg)
    if pgh is None:
        up = upper(pdk)
    elif pdk is None:
        up = upper(pgh)
    else:
        up = (1 - g) * upper(pdk) + g * upper(pgh)
    pts = np.array(pts + list(up))
    assert len(pts) == NH, len(pts)
    pts[-1, 0] = 0.0
    return pts


def ring(shape, s):
    """closed ring (x, Y) after the end rounding; index 0 = bottom centre, 1..NH-2 right, NH-1 top, then left.
    Plan rounding per row: rows up to the crease use 'plan', rows from the beltline up use 'plan_up' (rear)."""
    H = sample_half(shape, s)
    W, Yb, Yt, Wf, Bf, Tf = shape.outline(s)
    e = shape._end(s)
    H = H.copy()
    r0, r1 = ROW["crease0"], ROW["belt"]
    for j in range(NH):
        w = smoothstep(r0, r1, j)
        off = e["plan"] * (1 - w) + e["plan_up"] * w
        H[j, 0] *= (Wf - off) / Wf
    H[:, 1] = Yb + (H[:, 1] - Bf) * (Yt - Yb) / (Tf - Bf)
    left = H[1:NH - 1][::-1].copy(); left[:, 0] *= -1
    return np.vstack([H, left])


def stations(shape, extra=(), n_end=12, step=0.32):
    """station list: angular spacing in the end zones, ~step in the body, tighter in P['tight'] zones (s0, s1, step),
    plus every seam station; regular stations never sit closer than 0.06 to a seam station"""
    P = shape.P
    st = set()
    a = P["end_front"]["plan"][0]
    for k in range(0, n_end + 1):
        st.add(round(S_FRONT + a * (1 - math.cos(math.radians(90 * k / n_end))), 4))
    a2 = P["end_rear"]["plan"][0]
    for k in range(0, n_end + 1):
        st.add(round(S_REAR - a2 * (1 - math.cos(math.radians(90 * k / n_end))), 4))
    def local_step(s):
        for (z0, z1, zs) in P.get("tight", []):
            if z0 < s < z1:
                return zs
        return step
    s = S_FRONT + a + step
    while s < S_REAR - 0.01:
        stp = local_step(s)
        if s < S_REAR - a2 - step * 0.5 or stp < step:
            st.add(round(s, 4))
        s += stp
    st = sorted(v for v in st if all(abs(v - e) > min(0.06, 0.55 * local_step(v)) for e in extra) and S_FRONT <= v <= S_REAR)
    st = sorted(set(st) | {round(e, 4) for e in extra})
    out = [st[0]]
    for v in st[1:]:
        if v - out[-1] > 0.02:
            out.append(v)
    if out[-1] < S_REAR - 1e-6:
        if S_REAR - out[-1] < 0.02:
            out[-1] = S_REAR
        else:
            out.append(S_REAR)
    return out


def cap_grid(ring_pts, s_face, bulge, front=True):
    """Coons patch over the end ring: (M+1) x (N+1) points (x, Y, s); boundary = the ring"""
    M, N = 2 * NB, NS_
    R = ring_pts
    nr = len(R)
    bl, br, tr, tl = nr - NB, NB, NB + NS_, nr - NB - NS_
    bottom = [R[(bl + a) % nr] for a in range(M + 1)]
    right = [R[br + b] for b in range(N + 1)]
    top = [R[(tl - a) % nr] for a in range(M + 1)]
    left = [R[(bl - b) % nr] for b in range(N + 1)]
    G = np.zeros((M + 1, N + 1, 3))
    for a in range(M + 1):
        for b in range(N + 1):
            u, v = a / M, b / N
            p = ((1 - v) * bottom[a] + v * top[a] + (1 - u) * left[b] + u * right[b]
                 - ((1 - u) * (1 - v) * bottom[0] + u * (1 - v) * bottom[M] + (1 - u) * v * top[0] + u * v * top[M]))
            bz = bulge * (1 - (2 * u - 1) ** 2) ** 2 * (1 - (2 * v - 1) ** 2) ** 2
            G[a, b] = (p[0], p[1], s_face - bz if front else s_face + bz)
    for a in range(M + 1):
        G[a, 0, :2] = bottom[a]; G[a, N, :2] = top[a]; G[a, 0, 2] = G[a, N, 2] = s_face
    for b in range(N + 1):
        G[0, b, :2] = left[b]; G[M, b, :2] = right[b]; G[0, b, 2] = G[M, b, 2] = s_face
    return G


# ------------------------------------------------------------------------------------------------ wheel arches -----
# Angular (rounded-trapezoid) arch = trapezoid T (+- a_t at y_t, +- a_b at y_b, relative to the wheel centre) grown by a
# disk of radius r: opening top = y_t + r = 1.64 (spec arch radius), sides ~1.70 at the hub height, squarer corners.
ARCH = dict(a_t=0.55, y_t=0.54, a_b=0.70, y_b=-1.30, r=1.10)
FLARE_W = 0.32          # black arch cladding band width outside the opening


def _trap():
    A = ARCH
    return [(-A["a_t"], A["y_t"]), (-A["a_b"], A["y_b"]), (A["a_b"], A["y_b"]), (A["a_t"], A["y_t"])]   # CCW? (ds, dY)


def arch_outline(off=0.0, step_deg=4.0, seg_len=0.12):
    """closed outline (list of (ds, dY), counter-clockwise) of T grown by r + off"""
    T = _trap()
    # ensure CCW
    area = sum(T[i][0] * T[(i + 1) % 4][1] - T[(i + 1) % 4][0] * T[i][1] for i in range(4))
    if area < 0:
        T = T[::-1]
    r = ARCH["r"] + off
    n = len(T)
    out = []
    for i in range(n):
        p0, p1, p2 = np.array(T[i - 1]), np.array(T[i]), np.array(T[(i + 1) % n])
        e_in = p1 - p0; e_out = p2 - p1
        n_in = np.array([e_in[1], -e_in[0]]) / np.linalg.norm(e_in)      # outward normal (CCW polygon)
        n_out = np.array([e_out[1], -e_out[0]]) / np.linalg.norm(e_out)
        a0 = math.atan2(n_in[1], n_in[0]); a1 = math.atan2(n_out[1], n_out[0])
        while a1 < a0:
            a1 += 2 * math.pi
        k = max(1, int(math.ceil(math.degrees(a1 - a0) / step_deg)))
        for j in range(k + 1):
            a = a0 + (a1 - a0) * j / k
            out.append(p1 + r * np.array([math.cos(a), math.sin(a)]))
        # straight edge to the next vertex
        q0 = p1 + r * n_out; q1 = p2 + r * n_out
        L = np.linalg.norm(q1 - q0); m = max(1, int(math.ceil(L / seg_len)))
        for j in range(1, m):
            out.append(q0 + (q1 - q0) * j / m)
    return [tuple(p) for p in out]


def _dist_to_trap(p):
    T = [np.array(v) for v in _trap()]
    p = np.array(p)
    # inside test (convex): all cross products same sign
    n = len(T)
    signs = []
    for i in range(n):
        a, b = T[i], T[(i + 1) % n]
        signs.append((b[0] - a[0]) * (p[1] - a[1]) - (b[1] - a[1]) * (p[0] - a[0]))
    if all(sg >= 0 for sg in signs) or all(sg <= 0 for sg in signs):
        return 0.0
    best = 9e9
    for i in range(n):
        a, b = T[i], T[(i + 1) % n]
        ab = b - a; t = max(0.0, min(1.0, float(np.dot(p - a, ab) / np.dot(ab, ab))))
        best = min(best, float(np.linalg.norm(p - (a + ab * t))))
    return best


def in_arch_shape(ds, dY, off=0.0):
    """inside the opening grown by off (relative coords to the wheel centre)"""
    return _dist_to_trap((ds, dY)) < ARCH["r"] + off


def arch_dist(ds, dY):
    """signed distance-like value: distance to T minus r (negative inside the opening)"""
    return _dist_to_trap((ds, dY)) - ARCH["r"]
