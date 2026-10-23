# Pull the 9 chosen Cartoon City street props (RG Poly, CC0) out of the Godot zip, read-only, flat & short paths.
#   python -I extract_props.py <Cartoon City Massive Pack_Godot.zip> <out _src dir>
# The pack .glb files point at their texture as '../../Textures/city_atlas.png', so the models go to <out>/x/x/
# and the atlas to <out>/Textures/ (same relative depth, no long pack folder names -> no 260-char path problem).
# Nothing inside the zip is executed; only the 9 .glb + city_atlas.png are written.
import sys, os, zipfile, json, struct

PROPS = [  # (sheet no. in props_candidates.png, pack category, pack file name, our name)
    ("00", "Street Props", "Hydrant", "Prop_Hydrant"),
    ("01", "Street Props", "Cone_1", "Prop_Cone"),
    ("03", "Street Props", "PostBox_1_A", "Prop_Mailbox"),
    ("08", "Street Props", "Trashbag_A_1", "Prop_Trashbag"),
    ("13", "Street Props", "FireEscape_A_2", "Prop_FireEscapeStair"),
    ("18", "Other", "Tire", "Prop_Tire"),
    ("21", "Other", "Carnister", "Prop_GasCan"),
    ("41", "Nature and Park", "Trashbin_1_A", "Prop_ParkBin_1"),
    ("42", "Nature and Park", "Trashbin_1_B", "Prop_ParkBin_2"),
]

if __name__ == "__main__":
    zp, out = sys.argv[1], os.path.abspath(sys.argv[2])
    z = zipfile.ZipFile(zp)
    names = z.namelist()
    mdir = os.path.join(out, "x", "x"); tdir = os.path.join(out, "Textures")
    os.makedirs(mdir, exist_ok=True); os.makedirs(tdir, exist_ok=True)
    listing = []
    for no, cat, fn, ours in PROPS:
        hit = [n for n in names if n.endswith("/Models/" + cat + "/" + fn + ".glb")]
        assert len(hit) == 1, (fn, hit)
        d = z.read(hit[0])
        ln = struct.unpack("<I", d[12:16])[0]; j = json.loads(d[20:20 + ln])
        for im in j.get("images", []):
            uri = im.get("uri", "")
            assert uri.startswith("../../Textures/"), uri
            tail = uri.split("/")[-1]
            tp = os.path.join(tdir, tail)
            if not os.path.exists(tp):
                src = [n for n in names if n.endswith("/Textures/" + tail)]
                open(tp, "wb").write(z.read(src[0]))
        open(os.path.join(mdir, fn + ".glb"), "wb").write(d)
        listing.append({"sheet_no": no, "pack_path": hit[0], "file": "x/x/" + fn + ".glb", "ours": ours})
    json.dump(listing, open(os.path.join(out, "src_list.json"), "w", encoding="utf-8"), indent=1)
    print(len(listing), "props ->", mdir)
