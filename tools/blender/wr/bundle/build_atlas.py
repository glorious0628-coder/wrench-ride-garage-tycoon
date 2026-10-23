# One shared 1024 texture for all background cars (Cars Full pack, CC0):
#   top 1024 x 768  = pack city_atlas.png squeezed vertically (x 0.75)   -> UV v' = 0.25 + 0.75 v (Blender, v up)
#   bottom-left 256 x 256 = the grey glass cell of windows.png (its top-right third) -> UV (u-2/3)*0.75, (v-2/3)*0.75
#   rest = neutral grey (unused)
# Also writes the "worn" atlas (same layout; desaturated, darker, a little brown/dusty) for junkyard cars.
#   python -I build_atlas.py <city_atlas.png> <windows.png> <out_dir>
import sys, os
import numpy as np
from PIL import Image

ca, wi, out = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(out, exist_ok=True)
A = Image.open(ca).convert("RGB"); Wn = Image.open(wi).convert("RGB")
assert A.size == (1024, 1024) and Wn.size == (1024, 1024)
atlas = Image.new("RGB", (1024, 1024), (128, 128, 128))
atlas.paste(A.resize((1024, 768), Image.LANCZOS), (0, 0))
cell = Wn.crop((683, 0, 1024, 341)).resize((256, 256), Image.LANCZOS)   # image top-right third = grey glass
atlas.paste(cell, (0, 768))
atlas.save(os.path.join(out, "bg_cars_atlas.png"))


def worn(img, desat, dark, tint, dust):
    a = np.asarray(img).astype(np.float32) / 255.0
    lum = (a * np.array([0.299, 0.587, 0.114])).sum(-1, keepdims=True)
    a = a * (1 - desat) + lum * desat                     # desaturate
    a = a * dark                                          # darker
    a = a * np.array(tint)                                # brownish
    a = a * (1 - dust) + np.array([0.52, 0.48, 0.42]) * dust   # dusty film (lower contrast)
    return Image.fromarray((np.clip(a, 0, 1) * 255 + 0.5).astype(np.uint8))


w = worn(atlas, desat=0.55, dark=0.82, tint=(1.0, 0.96, 0.88), dust=0.12)
# glass: dirtier (more dust, lower contrast)
g = worn(atlas.crop((0, 768, 256, 1024)), desat=0.6, dark=0.85, tint=(1.0, 0.97, 0.9), dust=0.3)
w.paste(g, (0, 768))
w.save(os.path.join(out, "bg_cars_atlas_worn.png"))
print("atlas ok")
