# Wreck pass, step 2 (wr-3d-body, 10-21): rust / peeled clear coat / dust overlays in 3 levels, per body part, in the
# part's own UV layout (geometry maps from wreck_geo_bake.py). Concept: art/concepts/car_sedan/sedan_wreck_front/_rear.png
# + notes/gpt/main/wreck_main_decision.md: big damage shapes only (no small dots / moss / leaves), rust strongest on
# sills, wheel-arch lips, under the trunk lid / rear bumper bottom and bumper corners, peeled clear coat with crisp
# edges on the top surfaces. Levels are NESTED (light inside medium inside heavy) so restoring steps only remove damage.
#   py -I tools/blender/wr_body/wreck_maps.py <art/3d/sedan_body>
# writes  wreck/sedan_<part>_wreck<L>_color_overlay.png (+ _roughness.png)   L = 3 heavy, 2 medium, 1 light
#         wreck/sedan_glass_wreck<L>_color.png (dusty glass, opaque),  work/wreck/prev/*_prevcolor.png (blue paint, review)
import os, sys, json
import numpy as np
from PIL import Image
from scipy import ndimage as ndi

ROOT = sys.argv[1]
GEO = os.path.join(ROOT, "work", "wreck", "geo"); DEL = os.path.join(ROOT, "B_concept")
OUT = os.path.join(ROOT, "wreck"); PREV = os.path.join(ROOT, "work", "wreck", "prev")
os.makedirs(OUT, exist_ok=True); os.makedirs(PREV, exist_ok=True)
PAINT_DEFAULT = (9, 143, 252)
hexc = lambda h: np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], np.float32) / 255.0
C_RUST = hexc("#B4602C"); C_RUST_D = hexc("#6A361B"); C_PEEL = hexc("#EEF1F3"); C_DUST = hexc("#8E826F")
C_GRIME = hexc("#4B4034"); C_HALO = hexc("#3E2A1E"); C_GDUST = hexc("#9A9285")
LEVELS = {3: dict(rust=0.52, peel=0.625, dust=0.42, flat=0.24, seam=0.45, grime=0.62, glass=0.42, rough=0.72, fade=0.15),
          2: dict(rust=0.68, peel=0.685, dust=0.24, flat=0.10, seam=0.26, grime=0.40, glass=0.24, rough=0.58, fade=0.08),
          1: dict(rust=0.86, peel=9.0, dust=0.10, flat=0.03, seam=0.10, grime=0.18, glass=0.10, rough=0.48, fade=0.03)}
C_FADE = hexc("#C9CED3")        # code: MeshPart.Color = lerp(customer paint, C_FADE, fade) while the car is a wreck


def sstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0); return t * t * (3 - 2 * t)


def vnoise(p, seed):
    """3D value noise in 0..1 (smooth), p (N, 3)"""
    i = np.floor(p).astype(np.int64); f = p - i; u = f * f * (3 - 2 * f)
    out = 0.0
    for dx in (0, 1):
        for dy in (0, 1):
            for dz in (0, 1):
                h = ((i[:, 0] + dx) * 73856093) ^ ((i[:, 1] + dy) * 19349663) ^ ((i[:, 2] + dz) * 83492791) ^ (seed * 2654435761)
                h = (h ^ (h >> 13)) * 1274126177; h = (h ^ (h >> 16)) & 0xFFFF
                w = (u[:, 0] if dx else 1 - u[:, 0]) * (u[:, 1] if dy else 1 - u[:, 1]) * (u[:, 2] if dz else 1 - u[:, 2])
                out = out + w * (h / 65535.0)
    return out


def fbm(p, freq, oct_=3, seed=1, gain=0.5):
    s, a, tot = 0.0, 1.0, 0.0
    for k in range(oct_):
        s = s + a * vnoise(p * freq * (2.03 ** k), seed + 17 * k); tot += a; a *= gain
    return s / tot


def clean(mask, min_px):
    lab, n = ndi.label(mask)
    if n == 0:
        return mask
    size = ndi.sum(mask, lab, range(1, n + 1))
    keep = np.zeros(n + 1, bool); keep[1:] = size >= min_px
    return keep[lab]


def fill_out(img, cov):
    """copy the nearest covered texel into uncovered ones (no dark bleeding at UV seams)"""
    idx = ndi.distance_transform_edt(~cov, return_distances=False, return_indices=True)
    return img[idx[0], idx[1]]


def load(p, mode):
    return np.asarray(Image.open(p).convert(mode)).astype(np.float32) / 255.0


PARTS = {"Shell": "sedan_shell", "Hood": "sedan_hood", "Bumper_F": "sedan_bumper_f", "Bumper_R": "sedan_bumper_r"}
report = {}
for part, base in PARTS.items():
    P = np.load(os.path.join(GEO, part + "_pos.npy")); Nn = np.load(os.path.join(GEO, part + "_nrm.npy"))
    S = np.load(os.path.join(GEO, part + "_seam.npy")); C = np.load(os.path.join(GEO, part + "_cov.npy"))
    H, W = C.shape
    col = load(os.path.join(DEL, base + "_color.png"), "RGB"); paint = load(os.path.join(DEL, base + "_paintmask.png"), "L") > 0.5
    rough0 = load(os.path.join(DEL, base + "_roughness.png"), "L")
    lamp = load(os.path.join(DEL, base + "_emissive.png"), "L") > 0.5 if os.path.exists(os.path.join(DEL, base + "_emissive.png")) \
        else np.zeros((H, W), bool)
    ix = np.nonzero(C); p = P[ix]; n = Nn[ix]; seam = S[ix]
    x, Y, s = p[:, 0], p[:, 1], p[:, 2]; ax = np.abs(x)
    # ---- rust field (0..1 = how prone the spot is) --------------------------------------------------------------
    d_arch = np.minimum(np.abs(np.hypot(s + 5.0, Y - 1.375) - 1.525), np.abs(np.hypot(s - 5.0, Y - 1.375) - 1.525))
    z_arch = sstep(0.34, 0.0, d_arch) * sstep(2.2, 2.7, ax) * sstep(3.2, 2.5, Y)
    z_sill = sstep(1.42, 0.80, Y) * sstep(2.5, 3.0, ax) * sstep(-7.2, -6.6, s) * sstep(7.2, 6.6, s)
    z_seam = sstep(0.09, 0.0, seam) * 0.62 * sstep(3.0, 1.6, Y)                          # lower door / fender gaps
    z_seam = np.maximum(z_seam, sstep(0.09, 0.0, seam) * 0.40)
    z_corner = np.zeros_like(Y)
    if part.startswith("Bumper"):
        z_corner = sstep(2.3, 3.4, ax) * sstep(2.5, 1.6, Y) * 0.95 + sstep(1.25, 0.85, Y) * 0.80
    if part == "Bumper_R":
        z_corner = np.maximum(z_corner, sstep(1.55, 0.95, Y) * 1.0)                         # rear bumper bottom: strong
    z_trunk = np.zeros_like(Y)
    if part == "Shell":
        z_trunk = sstep(6.9, 7.7, s) * np.exp(-((Y - 3.30) / 0.30) ** 2) * sstep(3.3, 2.0, ax) * 0.95   # trunk lid lower edge
        z_trunk = np.maximum(z_trunk, sstep(6.5, 7.4, s) * sstep(1.7, 1.1, Y))                         # under the trunk
    field = np.maximum.reduce([z_arch, z_sill, z_seam, z_corner, z_trunk])
    n1 = fbm(p, 2.2, 4, seed=11); n2 = fbm(p, 0.9, 2, seed=7)                               # patches inside the zones
    rv = field * (0.30 + 1.15 * n1) * (0.65 + 0.7 * n2)
    # ---- peeled clear coat: top surfaces of the roof / hood / trunk, big patches with crisp edges -------------
    up = sstep(0.70, 0.85, n[:, 1])                                                         # roof, hood, trunk lid only
    # irregular flaking edge: a small high-frequency term only moves the outline (shapes stay whole, no speckle)
    pz = (fbm(p, 1.0, 3, seed=23) + 0.075 * (fbm(p, 7.5, 2, seed=29) - 0.5)) * up * sstep(0.03, 0.10, seam)
    pin = 0.30 + 0.32 * fbm(p, 2.6, 2, seed=37)                                              # chalky, uneven inside
    up_s = sstep(0.55, 0.85, n[:, 1]); fl = 0.6 + 0.8 * fbm(p, 1.4, 2, seed=43)              # dust on flat tops
    seam_d = sstep(0.10, 0.0, seam)                                                          # dirt in panel gaps
    # ---- dust ----------------------------------------------------------------------------------------------
    dz = 0.75 + 0.5 * fbm(p, 0.6, 2, seed=31)
    grime_f = np.maximum(sstep(2.2, 0.7, Y), 0.6 * z_arch)
    rough_paint = rough0[ix]
    base_rgb = col[ix]; is_paint = paint[ix]; is_lamp = lamp[ix]
    report[part] = {}
    for L, cfg in LEVELS.items():
        rust = (rv > cfg["rust"]) & is_paint
        peel = (pz > cfg["peel"]) & is_paint & ~rust
        R2 = np.zeros((H, W), bool); R2[ix] = rust; R2 = clean(R2, max(12, int(25 * (W / 2048) ** 2)))
        P2 = np.zeros((H, W), bool); P2[ix] = peel; P2 = clean(P2, max(70, int(320 * (W / 2048) ** 2)))   # big patches only (GPT: no speckle)
        # anti-aliased edges (crisp but not stair-stepped): soft ramp limited to the cleaned shapes + 1 px
        Rk = ndi.binary_dilation(R2)[ix]; Pk = ndi.binary_dilation(P2)[ix]
        rust_a = (sstep(cfg["rust"] - 0.03, cfg["rust"] + 0.03, rv) * Rk * is_paint).astype(np.float32)
        peel_a = (sstep(cfg["peel"] - 0.006, cfg["peel"] + 0.006, pz) * Pk * is_paint * (rust_a < 0.5)).astype(np.float32)
        rust = R2[ix]; peel = P2[ix]
        edge = (P2 & ~ndi.binary_erosion(P2, iterations=1))[ix]                               # crisp peel outline
        a_dust = np.clip(cfg["dust"] * dz + cfg["flat"] * up_s * fl, 0, 0.9)
        a_grime = np.clip(cfg["grime"] * grime_f + cfg["seam"] * seam_d, 0, 0.9)
        # paint texels: transparent paint + layers (alpha over)
        rgb = np.zeros_like(base_rgb); al = np.zeros(len(Y), np.float32)

        def over(rgb, al, c, a):
            a = a[:, None] if np.ndim(a) else np.full((len(al), 1), a, np.float32)
            out_a = a[:, 0] + al * (1 - a[:, 0])
            num = c * a + rgb * (al * (1 - a[:, 0]))[:, None]
            return np.where(out_a[:, None] > 1e-6, num / np.maximum(out_a, 1e-6)[:, None], 0), out_a
        rgb, al = over(rgb, al, C_DUST, a_dust)
        rgb, al = over(rgb, al, C_GRIME, a_grime)
        pk = peel.astype(np.float32)
        rgb, al = over(rgb, al, C_PEEL, peel_a * pin)                                         # no uniform rim
        ex = np.clip((rv - cfg["rust"]) / 0.30, 0, 1)
        rcol = C_RUST[None] * (1 - ex[:, None]) + C_RUST_D[None] * ex[:, None]
        halo = (ndi.binary_dilation(R2, iterations=max(1, W // 700)) & ~R2)[ix] & is_paint      # darker lifted-paint rim
        rgb, al = over(rgb, al, C_HALO, halo.astype(np.float32) * 0.55)
        rgb, al = over(rgb, al, rcol, rust_a)
        # non-paint texels (black trim, lamps, grille...): opaque base dusted / grimed
        npaint = ~is_paint
        nb = base_rgb.copy()
        nb = nb * (1 - a_dust[:, None] * 0.8) + C_DUST * (a_dust[:, None] * 0.8)
        nb = nb * (1 - a_grime[:, None]) + C_GRIME * a_grime[:, None]
        rgb = np.where(npaint[:, None], nb, rgb); al = np.where(npaint, 1.0, al)
        ro = np.where(is_paint, np.maximum(rough_paint, cfg["rough"]), rough_paint)
        ro = np.maximum(ro, 0.5 + 0.35 * a_dust + 0.3 * a_grime)
        ro = ro + (0.85 - ro) * peel_a; ro = ro + (0.92 - ro) * rust_a
        ro = np.where(is_lamp, np.maximum(rough_paint, 0.25 + a_dust), ro)
        img = np.zeros((H, W, 4), np.float32); img[ix[0], ix[1], :3] = rgb; img[ix[0], ix[1], 3] = al
        img = fill_out(img, C)
        rim = np.zeros((H, W), np.float32); rim[ix] = ro; rim = fill_out(rim, C)
        Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(os.path.join(OUT, f"{base}_wreck{L}_color_overlay.png"))
        Image.fromarray((np.clip(rim, 0, 1) * 255 + 0.5).astype(np.uint8), "L").save(os.path.join(OUT, f"{base}_wreck{L}_roughness.png"))
        # review: blue paint under the overlay
        pc = np.array(PAINT_DEFAULT, np.float32) / 255.0
        pc = pc * (1 - cfg["fade"]) + C_FADE * cfg["fade"]
        prev = img[..., :3] * img[..., 3:4] + pc * (1 - img[..., 3:4])
        Image.fromarray((np.clip(prev, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(PREV, f"{base}_wreck{L}_prevcolor.png"))
        orm = np.stack([np.ones_like(rim), rim, np.zeros_like(rim)], -1)
        Image.fromarray((orm * 255 + 0.5).astype(np.uint8)).save(os.path.join(PREV, f"{base}_wreck{L}_orm.png"))
        pa = max(1, int(is_paint.sum()))
        report[part][L] = dict(rust_pct_of_paint=round(100 * float(rust.sum()) / pa, 1), peel_pct_of_paint=round(100 * float(peel.sum()) / pa, 1))
    print(part, report[part])
# ---- glass: dust film (heavier low and at the edges), opaque colour map variant
P = np.load(os.path.join(GEO, "Glass_pos.npy")); C = np.load(os.path.join(GEO, "Glass_cov.npy")); S = np.load(os.path.join(GEO, "Glass_seam.npy"))
col = load(os.path.join(DEL, "sedan_glass_color.png"), "RGB"); ix = np.nonzero(C); p = P[ix]
for L, cfg in LEVELS.items():
    low = sstep(4.7, 3.9, p[:, 1])                                                           # wiper / sill edge of each pane
    edge_g = sstep(0.30, 0.0, S[ix])
    a = np.clip(cfg["glass"] * (0.55 + 0.9 * fbm(p, 1.2, 3, seed=41)) + cfg["glass"] * 0.9 * edge_g + cfg["glass"] * 0.7 * low, 0, 0.80)
    gc = C_GDUST[None] * (1 - 0.5 * low[:, None]) + C_GRIME[None] * (0.5 * low[:, None])
    rgb = col[ix] * (1 - a[:, None]) + gc * a[:, None]
    img = np.zeros(C.shape + (3,), np.float32); img[ix] = rgb; img = fill_out(img, C)
    Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(OUT, f"sedan_glass_wreck{L}_color.png"))
    Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8)).save(os.path.join(PREV, f"sedan_glass_wreck{L}_prevcolor.png"))
json.dump(report, open(os.path.join(ROOT, "work", "wreck", "wreck_cover.json"), "w"), indent=1)
print("MAPS DONE")
