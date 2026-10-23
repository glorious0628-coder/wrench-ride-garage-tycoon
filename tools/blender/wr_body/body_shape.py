# Sedan body outer surface as a smooth lofted grid (wr-3d-body, 10-21).
# Pure numpy (runs inside Blender and in plain python). Car coords = car_spec / Roblox local:
#   x = right (+), Y = up, s = Roblox Z (front = -8.4, rear = +8.6). 1 unit = 1 stud. Origin = ground between the axles.
# The surface = rings (one per station along s) with a fixed row structure + two grid end caps (box topology):
#   half ring H[0..33]: 0 = bottom centre, 8 = bottom corner, 14..16 = shoulder crease, 20 = beltline / hood seam /
#   window base, 23 = window (DLO) top, 25 = roof edge (top-right corner), 27 = roof inner (A/C pillar inner edge),
#   33 = top centre. Every feature line is a ROW, so seams cut along clean lines.
# Shape numbers: car_spec v0.4 (17 x 7.6 x 5.8, wheelbase 10, hood hinge (0, 3.05, -3.85), windshield base
# (-3.8, 3.1), bumpers 0.6..2.6) + the 6-view concept v3 (side profile, front/back sections, bottom-view plan).
import math
import numpy as np

S_FRONT, S_REAR = -8.37, 8.57      # + 0.03 cap bulge = -8.40 .. 8.60 (17.0)
NB, NS_, NT = 6, 17, 6          # half-ring segments: bottom, side, top
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


# ---------------------------------------------------------------- variant A: car_spec heights (hinge 3.05) ----
SPEC_A = dict(
    name="A_spec",
    # centreline top: hood (front part, ends at the windshield base) and cabin/deck (from the windshield base)
    top_hood=[(-8.4, 2.80), (-8.0, 2.78), (-7.0, 2.85), (-6.0, 2.93), (-5.0, 2.99), (-4.3, 3.05), (-3.80, 3.11)],
    top_cabin=[(-3.80, 3.11), (-3.3, 3.48), (-2.6, 4.00), (-1.8, 4.58), (-1.0, 5.10), (-0.4, 5.44), (0.4, 5.67),
               (1.4, 5.79), (2.4, 5.80), (3.3, 5.73), (4.2, 5.53), (5.0, 5.22), (5.8, 4.80), (6.5, 4.40), (6.97, 4.10)],
    top_deck=[(6.97, 4.10), (7.4, 4.00), (7.9, 4.02), (8.6, 4.05)],
    belt=[(-8.4, 2.72), (-8.0, 2.74), (-7.0, 2.80), (-6.0, 2.88), (-5.0, 2.95), (-4.3, 3.00), (-3.8, 3.05),
          (-3.3, 3.17), (-2.8, 3.28), (-2.0, 3.37), (-1.0, 3.44), (0.3, 3.51), (1.5, 3.57), (3.0, 3.65),
          (4.2, 3.72), (5.5, 3.79), (6.97, 3.86), (8.0, 3.92), (8.6, 3.93)],
    crease=[(-8.4, 2.50), (-7.5, 2.57), (-6.5, 2.67), (-5.0, 2.80), (-3.0, 2.93), (0.0, 3.06), (3.0, 3.17),
            (5.0, 3.24), (7.0, 3.31), (8.6, 3.36)],
    gh=(-3.80, -2.75, 6.25, 6.97),        # greenhouse factor ramps: 0 at gh[0] -> 1 at gh[1], 1 at gh[2] -> 0 at gh[3]
    ybot=[(-8.4, 0.62), (-7.3, 0.62), (-6.6, 0.58), (-6.0, 0.56), (6.0, 0.56), (6.7, 0.62), (7.5, 0.66), (8.6, 0.66)],
    width_core=3.76, width_hip=0.04,      # plan half width: 3.76 at the doors, 3.80 over the wheels
    end_front=dict(plan=(2.1, 2.4), top=(0.42, 0.58), bot=(0.35, 0.30)),   # (length a, size b) ellipses
    end_rear=dict(plan=(2.0, 2.0), top=(0.55, 1.58), bot=(0.35, 0.35)),
    shelf=0.50,                           # shoulder: crease -> beltline step in (plan)
    tumble=0.445,                         # side glass lean (tan 24 deg)
    crown_roof=0.30,                      # roof edge below the centre top
)

# ---------------------------------------------------------------- variant B: concept heights (for comparison) -----
SPEC_B = dict(SPEC_A)
SPEC_B.update(
    name="B_concept",
    # heights read off the concept side cell (roof normalised to 5.8, length stretched to 17); plan, wheels, length,
    # width, height = car_spec. Adopted (main + GPT 10-21). 2nd pass: fastback rear (roof -> rear glass -> trunk lip one
    # curve, lower rounder tail), rounder nose top, crease as a real ridge with a concave band under it.
    top_hood=[(-8.4, 3.02), (-8.2, 3.18), (-7.9, 3.40), (-7.5, 3.62), (-7.0, 3.80), (-6.5, 3.92), (-6.0, 4.00),
              (-5.0, 4.10), (-4.3, 4.16), (-3.80, 4.20)],
    top_cabin=[(-3.80, 4.20), (-3.45, 4.60), (-3.0, 4.86), (-2.5, 5.12), (-2.0, 5.33), (-1.5, 5.51), (-1.0, 5.63),
               (-0.5, 5.71), (0.2, 5.78), (1.2, 5.80), (2.4, 5.79), (3.2, 5.75), (3.9, 5.63), (4.6, 5.42), (5.2, 5.18),
               (5.8, 4.92), (6.4, 4.65), (6.97, 4.45), (7.5, 4.30), (8.0, 4.17), (8.6, 4.06)],
    top_deck=[(6.97, 4.45), (7.5, 4.30), (8.0, 4.17), (8.6, 4.06)],
    deck_merge=True,
    belt=[(-8.4, 2.95), (-8.0, 3.22), (-7.5, 3.50), (-7.0, 3.68), (-6.0, 3.86), (-5.0, 3.94), (-4.3, 3.97),
          (-3.8, 3.97), (-3.3, 3.93), (-2.8, 3.90), (-2.0, 3.90), (-1.0, 3.92), (0.3, 3.95), (1.5, 3.99),
          (3.0, 4.05), (4.2, 4.10), (5.5, 4.15), (6.97, 4.17), (7.5, 4.08), (8.0, 3.97), (8.6, 3.86)],
    crease=[(-8.4, 2.85), (-7.8, 3.00), (-7.0, 3.18), (-6.0, 3.32), (-5.0, 3.40), (-3.0, 3.46), (0.0, 3.50),
            (3.0, 3.56), (5.0, 3.60), (6.0, 3.62), (7.0, 3.60), (8.0, 3.55), (8.6, 3.50)],
    gh=(-3.80, -3.15, 6.0, 7.1),
    rear_deck_inset=0.95,
    ybot=[(-8.4, 0.80), (-7.3, 0.76), (-6.6, 0.62), (-6.0, 0.56), (6.0, 0.56), (6.7, 0.64), (7.4, 0.80), (8.0, 0.95),
          (8.6, 1.00)],
    end_front=dict(plan=(2.1, 2.4), top=(0.45, 0.55), bot=(0.35, 0.30)),
    end_rear=dict(plan=(2.2, 2.2), top=(0.45, 1.05), bot=(0.55, 0.45)),
    tumble=0.41,
    crown_roof=0.20, dlo_gap=0.12,      # concept: window top only ~0.3 below the roof line (thin roof rail / A-pillar)
    undercut=0.50, crease_in=0.11, crease_handle=0.22,
    # shoulder crease = ridge with a short undercut right below it (casts a shadow line) + shallow band; colour pass:
    # raised (0.22/0.05 -> 0.50/0.11) so it carries past the doors in the 3/4 view (GPT: rear part was weak)
)


class Shape:
    def __init__(self, P):
        self.P = P
        self.f_top_hood = pchip(P["top_hood"]); self.f_top_cabin = pchip(P["top_cabin"]); self.f_top_deck = pchip(P["top_deck"])
        self.f_belt = pchip(P["belt"]); self.f_crease = pchip(P["crease"]); self.f_ybot = pchip(P["ybot"])
        self.s_ws = P["top_cabin"][0][0]; self.s_rg = P["top_deck"][0][0]

    # ---- full (un-rounded) profile curves
    def top_full(self, s):
        if s <= self.s_ws:
            return self.f_top_hood(s)
        if s <= self.s_rg or self.P.get("deck_merge"):     # deck_merge: roof -> rear glass -> trunk = one curve (fastback)
            return self.f_top_cabin(s)
        return self.f_top_deck(s)

    def width_full(self, s):
        P = self.P
        return P["width_core"] + P["width_hip"] * (math.exp(-((s + 5) / 1.6) ** 2) + math.exp(-((s - 5) / 1.6) ** 2))

    def gfac(self, s):
        a, b, c, d = self.P["gh"]
        return smoothstep(a, b, s) * (1 - smoothstep(c, d, s))

    # ---- end rounding (ellipse quadrants): offsets that reach (a, b) at the tips
    def _end(self, s):
        P = self.P
        if s < 0:
            d = s - S_FRONT; e = P["end_front"]
        else:
            d = S_REAR - s; e = P["end_rear"]
        out = {}
        for k in ("plan", "top", "bot"):
            a, b = e[k]
            if d >= a:
                out[k] = 0.0
            else:
                t = 1 - max(d, 0.0) / a
                out[k] = b * (1 - math.sqrt(max(0.0, 1 - t * t)))
        return out

    def outline(self, s):
        """(W, Ybot, Ytop) after the end rounding + the full ones"""
        e = self._end(s)
        Wf, Bf, Tf = self.width_full(s), self.f_ybot(s), self.top_full(s)
        return Wf - e["plan"], Bf + e["bot"], Tf - e["top"], Wf, Bf, Tf

    # ---- half section (dense curve pieces between anchors) at full size
    def half_section(self, s):
        P = self.P
        W, Yb, Yt = self.width_full(s), self.f_ybot(s), self.top_full(s)
        Ybl, Ycr = self.f_belt(s), self.f_crease(s)
        Ycr = min(Ycr, Ybl - 0.08)
        g = self.gfac(s)
        # the shoulder fades toward the nose / tail so the crease ends in the lamps instead of wrapping the fascia
        fade = 1.0
        if s < -7.0:
            fade = 0.45 + 0.55 * smoothstep(S_FRONT, -7.0, s)
        if s > 7.9:
            fade = 0.45 + 0.55 * (1 - smoothstep(7.9, S_REAR, s))
        shelf = P["shelf"] * fade
        x_bl = W - 0.035 - shelf
        V = lambda x, y: np.array([x, y], float)
        nrm = lambda v: v / np.linalg.norm(v)
        # lower body
        rb = 0.30; tuck = 0.07
        Pb = V(W - tuck - rb, Yb)
        A1 = V(W - tuck - rb + rb * math.sin(math.radians(45)), Yb + rb - rb * math.cos(math.radians(45)))
        Ps = V(W - tuck, Yb + rb)
        Ym = 0.5 * (Yb + rb + Ycr - 0.05)
        A2 = V(W, Ym)
        C = V(W - 0.005, Ycr)              # crease line: crisp, the side just under it tucks in a little (shadow line)
        up_in = nrm(V(P.get("undercut", 0.10), 1.0))   # surface comes up OUTWARD into the crease (concave band below)
        B = V(x_bl, Ybl)
        sh_dir = nrm(B - C)
        A3 = C - up_in * P.get("crease_in", 0.035)
        A4 = C + sh_dir * 0.04
        A5 = B - sh_dir * 0.05
        # deck (hood / trunk lid) above the beltline: crowned curve from the edge to the centre
        pdeck = 2.4
        crown_deck = max(Yt - Ybl, 0.02)
        deck_y = lambda x: Yt - crown_deck * (abs(x) / x_bl) ** pdeck
        deck_dir = nrm(V(-1.0, crown_deck * pdeck / x_bl))
        pieces_deck = None; pieces_gh = None
        common = [("arc", (Pb, A1, rb, V(W - tuck - rb, Yb + rb)), 2)]
        # ---------- deck mode
        if g < 1.0:
            A6 = V(x_bl - 0.05, deck_y(x_bl - 0.05))
            if s > 0 and P.get("rear_deck_inset"):          # rear: C-pillar rows spread wide on the deck (glass narrows)
                k = P["rear_deck_inset"]
                xs = [x_bl - 0.05, x_bl - 0.16, x_bl - 0.30, x_bl - k, 0.0]
            else:
                xs = [x_bl - 0.05, x_bl - 0.14, x_bl - 0.24, x_bl - 0.45, 0.0]
            pieces_deck = dict(A5=A5, A6=A6, belt_out=deck_dir,
                               up=[("fn", (deck_y, xs[0], xs[1]), 3), ("fn", (deck_y, xs[1], xs[2]), 2),
                                   ("fn", (deck_y, xs[2], xs[3]), 2), ("fnc", (deck_y, xs[3], 0.0), NT - 2)])
        # ---------- greenhouse mode
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
            # roof edge rounding: one cubic A7 -> A9, split at the middle (A8 = top-right corner)
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
    """n segments by arc length along a dense polyline (returns n+1 points incl. both ends)"""
    d = np.r_[0, np.cumsum(np.linalg.norm(np.diff(dense, axis=0), axis=1))]
    u = np.linspace(0, 1, n + 1)
    if bias == "start":      # denser near the start (roof edge side of the crown)
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
        a, b, r, c = args      # from a to b around centre c
        a0 = math.atan2(a[1] - c[1], a[0] - c[0]); a1 = math.atan2(b[1] - c[1], b[0] - c[0])
        t = np.linspace(a0, a1, 30)
        return _resample(np.stack([c[0] + r * np.cos(t), c[1] + r * np.sin(t)], 1), n)
    raise ValueError(kind)


def sample_half(shape, s):
    """34 (x, Y) points of the right half section at station s (full size, before end rounding)"""
    lower, pdk, pgh, g = shape.half_section(s)
    W, Yb = lower["W"], lower["Yb"]
    pts = []
    bot = _resample(np.array([[0.0, Yb], lower["Pb"]]), NB - 2)                 # flat segments
    pts += list(bot)
    c = np.array([W - lower["tuck"] - lower["rb"], Yb + lower["rb"]])
    pts += list(_piece("arc", (lower["Pb"], lower["A1"], lower["rb"], c), 2)[1:])  # -> A1 (index 8)
    pts += list(_piece("arc", (lower["A1"], lower["Ps"], lower["rb"], c), 1)[1:])  # -> Ps (9)
    A2, A3, A4 = lower["A2"], lower["A3"], lower["A4"]
    Ps = lower["Ps"]
    L = np.linalg.norm(A2 - Ps)
    pts += list(_piece("bez", (Ps, Ps + np.array([0.012, 1.0]) * L * 0.4, A2 - np.array([0, 1.0]) * L * 0.4, A2), 2)[1:])  # 11
    L = np.linalg.norm(A3 - A2)
    hA3 = shape.P.get("crease_handle", 0.4)
    pts += list(_piece("bez", (A2, A2 + np.array([0, 1.0]) * L * 0.4, A3 - lower["up_in"] * L * hA3, A3), 3)[1:])  # 14
    # crease: tight turn from 'up' to the shoulder direction
    C = lower["C"]
    pts += list(_piece("bez", (A3, A3 + lower["up_in"] * 0.02, A4 - lower["sh_dir"] * 0.02, A4), 2)[1:])  # crease

    def upper(pc):
        A5, A6 = pc["A5"], pc["A6"]
        L = np.linalg.norm(A5 - A4)
        sh = lower["sh_dir"]
        # slightly convex shoulder (bulges outward)
        out = np.array([sh[1], -sh[0]])
        seg = list(_piece("bez", (A4, A4 + sh * L * 0.35 + out * 0.025, A5 - sh * L * 0.35 + out * 0.025, A5), 3)[1:])  # 19
        Lb = np.linalg.norm(A6 - A5)
        seg += list(_piece("bez", (A5, A5 + sh * Lb * 0.45, A6 - pc["belt_out"] * Lb * 0.45, A6), 1)[1:])  # 20
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
    """closed ring (x, Y) after the end rounding; index 0 = bottom centre, 1..NH-2 right, NH-1 top, then left"""
    H = sample_half(shape, s)
    W, Yb, Yt, Wf, Bf, Tf = shape.outline(s)
    H = H.copy()
    H[:, 0] *= W / Wf
    H[:, 1] = Yb + (H[:, 1] - Bf) * (Yt - Yb) / (Tf - Bf)
    left = H[1:NH - 1][::-1].copy(); left[:, 0] *= -1
    return np.vstack([H, left])


def stations(shape, extra=(), n_end=12, step=0.32, tight=0.15):
    """station list: angular spacing in the end zones, ~step in the body (tight at the windshield / rear glass
    bases), plus every seam station; regular stations never sit closer than 0.06 to a seam station"""
    P = shape.P
    st = set()
    a = P["end_front"]["plan"][0]
    for k in range(0, n_end + 1):
        st.add(round(S_FRONT + a * (1 - math.cos(math.radians(90 * k / n_end))), 4))
    a2 = P["end_rear"]["plan"][0]
    for k in range(0, n_end + 1):
        st.add(round(S_REAR - a2 * (1 - math.cos(math.radians(90 * k / n_end))), 4))
    s = S_FRONT + a + step
    while s < S_REAR - a2 - step * 0.5:
        stp = tight if (-4.05 < s < -2.7 or 5.9 < s < 7.2) else (0.40 if -2.6 < s < 4.4 else step)
        st.add(round(s, 4)); s += stp
    st = sorted(v for v in st if all(abs(v - e) > 0.06 for e in extra))
    st = sorted(set(st) | {round(e, 4) for e in extra})
    out = [st[0]]
    for v in st[1:]:
        if v - out[-1] > 0.02:
            out.append(v)
    return out


def cap_grid(ring_pts, s_face, bulge, front=True):
    """Coons patch over the end ring: (M+1) x (N+1) points (x, Y, s); boundary = the ring"""
    M, N = 2 * NB, NS_
    R = ring_pts
    nr = len(R)
    bl, br, tr, tl = nr - NB, NB, NB + NS_, nr - NB - NS_     # 58, 8, 25, 41
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
    for a in range(M + 1):     # exact boundary
        G[a, 0, :2] = bottom[a]; G[a, N, :2] = top[a]; G[a, 0, 2] = G[a, N, 2] = s_face
    for b in range(N + 1):
        G[0, b, :2] = left[b]; G[M, b, :2] = right[b]; G[0, b, 2] = G[M, b, 2] = s_face
    return G
