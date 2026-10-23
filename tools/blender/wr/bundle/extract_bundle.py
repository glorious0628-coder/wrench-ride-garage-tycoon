# Pull only the vehicle files we need out of the bought itch bundle zips into SHORT flat folders
# (Windows 260-char path limit). Run with:  python -I extract_bundle.py <bundle_dir> <src_out_dir> [what]
#   what = "base"  : Cars Full (Godot .glb, all colour variants, small) + its Textures,
#                    Cars 2 (Gltf .glb) variant A of every type, one Cartoon City sample (duplicate check)
#   what = "c2:<name>,<name>"  : extra Cars 2 files by exact file name (e.g. Car_3_MC_B.glb)
# The Cars Full Godot .glb files point at '../../Textures/x.png', so the layout keeps Models/<grp>/x.glb + Textures/.
# Nothing inside the packs is executed; zips are only read.
import sys, os, zipfile, re

bundle, out = sys.argv[1], sys.argv[2]
what = sys.argv[3] if len(sys.argv) > 3 else "base"


def put(z, member, dest):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    if os.path.exists(dest) and os.path.getsize(dest) == z.getinfo(member).file_size:
        return 0
    with z.open(member) as f, open(dest, "wb") as g:
        g.write(f.read())
    return 1


n = 0
if what == "base":
    z = zipfile.ZipFile(os.path.join(bundle, "cars_1", "Cars Full_Godot.zip"))
    for m in z.namelist():
        if m.endswith(".glb") and m.startswith("Cars Full/Models/"):
            grp, fn = m.split("/")[2], m.split("/")[3]
            n += put(z, m, os.path.join(out, "c1", "Models", grp, fn))
        elif m.startswith("Cars Full/Textures/") and m.endswith(".png"):
            n += put(z, m, os.path.join(out, "c1", "Textures", m.rsplit("/", 1)[1]))
        elif m == "Cars Full/README_PL.txt":
            n += put(z, m, os.path.join(out, "c1", "README_PL.txt"))
    z = zipfile.ZipFile(os.path.join(bundle, "cars_2", "Cars.zip"))
    for m in z.namelist():
        fn = m.rsplit("/", 1)[-1]
        if m.startswith("Cars/Gltf/") and fn.endswith(".glb"):
            # variant A (or first) of each type
            if re.search(r"_(A|1_A|1A|A_1)\.glb$", fn) or fn in ("Taxi_5_MC_B.glb",):
                n += put(z, m, os.path.join(out, "c2", fn))
        elif m.startswith("Cars/Textures/") and fn.endswith(".png"):
            n += put(z, m, os.path.join(out, "c2", "Textures", fn))
    z = zipfile.ZipFile(os.path.join(bundle, "cartoon_city", "Cartoon City Massive Pack_Godot.zip"))
    for m in z.namelist():
        if m.endswith("Vehicles/Car 1/Car_1_A.glb") or m.endswith("Vehicles/Car 7/Car_7_A.glb"):
            n += put(z, m, os.path.join(out, "cc", m.rsplit("/", 1)[1]))
elif what.startswith("c2:"):
    names = set(what[3:].split(","))
    z = zipfile.ZipFile(os.path.join(bundle, "cars_2", "Cars.zip"))
    for m in z.namelist():
        fn = m.rsplit("/", 1)[-1]
        if m.startswith("Cars/Gltf/") and fn in names:
            n += put(z, m, os.path.join(out, "c2", fn))
print("extracted", n)
