# Spark plug socket + extension (wr 3D helper 10-22), measured on art/concepts/tools/spark_plug_socket_6view.png front view
# (row profile; its two end views are drawn at another scale and are not used for size).
# Real: 3/8" drive 5/8" (16 mm) thin-wall deep socket with a black rubber insert that holds the plug's porcelain, on a
# ~6" extension: female square drive on top (the ratchet's male drive goes in), knurled grip band (here with a red
# sleeve), male end hidden inside the socket (ref_tools_firstbatch 2, tools_real 2-3).
# Game fit (engine_bay_v2 parts_def.py): plug hex circumradius 0.047 / 0.05 tall, plug well diameter 0.156 ->
# socket OD 0.125, hex opening circumradius 0.050. Total 1.10 stud.
# Build frame: the tool stands along Z, socket mouth at z = 0 (origin, pointing down -Z), drive end on top (z = 1.10).
#   blender -b --factory-startup --python build_plug_socket.py -- <out_dir> [palette.json]
import bpy, bmesh, sys, os, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tv2_lib as T
from tv2_lib import W, P, Vector, Matrix, np, rb

OUT, PAL = T.args()
C = lambda n, d: PAL.get(n, d)
TOP = 1.10
R_SOCK, R_HEX, HEX_D = 0.0625, 0.050, 0.09        # socket OD radius, hex opening circumradius, hex recess depth
R_ROD = 0.0326
DRIVE_HS, DRIVE_D = 0.021, 0.06                   # 3/8" female square (x1.3), depth

P.reset()
chrome = P.mat("chrome", C("chrome", "#BCC1CC"), 0.30, 0.75)
inside = P.mat("inside", C("inside", "#3A3B3F"), 0.55, 0.5)
rubber = P.mat("rubber", C("rubber", "#1C1C1E"), 0.85, 0.0)
red = P.mat("sleeve", C("sleeve", "#C92D31"), 0.6, 0.0)
parts = []
N_S = 24
hexr = T.hex_r(R_HEX, 0.0)
# ---- socket: rubber floor -> hex walls -> mouth -> outer wall -> shoulder -> drive collar -> top (rod goes in)
sock = T.lathe_rings("socket", [
    (HEX_D, hexr), (0.0, hexr), (0.0, R_SOCK - 0.006), (0.006, R_SOCK), (0.325, R_SOCK), (0.336, R_SOCK - 0.005),
    (0.345, 0.050), (0.405, 0.050), (0.417, 0.046), (0.426, 0.036)], N_S, chrome, pole0=HEX_D, pole1=0.426)
P.assign_by(sock, lambda c, n: rubber if (c.z > HEX_D - 0.002 and n.z < -0.9 and math.hypot(c.x, c.y) < R_HEX)
            else inside if (c.z < HEX_D and c.z > 0.0005 and math.hypot(c.x, c.y) < R_HEX + 0.001) else None)
parts.append(sock)
# ---- extension: rod, knurl, red sleeve, knurl, rod, female drive end (square hole on top)
N_E = 16
sq = T.square_r(DRIVE_HS, math.pi / 4)
ext = T.lathe_rings("ext", [
    (0.40, R_ROD), (0.552, R_ROD), (0.556, 0.0345), (0.612, 0.0345), (0.618, 0.0372), (0.626, 0.0398), (0.740, 0.0398),
    (0.748, 0.0372), (0.754, 0.0345), (0.800, 0.0345), (0.804, R_ROD), (0.982, R_ROD), (0.994, 0.0405), (1.004, 0.0437),
    (TOP - 0.010, 0.0437), (TOP, 0.0395), (TOP, sq), (TOP - DRIVE_D, sq)], N_E, chrome, pole0=0.40, pole1=TOP - DRIVE_D)
P.assign_by(ext, lambda c, n: red if 0.614 < c.z < 0.752 and math.hypot(c.x, c.y) > 0.036
            else inside if (c.z > TOP - DRIVE_D - 0.001 and math.hypot(c.x, c.y) < DRIVE_HS * 1.45 and c.z < TOP - 0.0005) else None)
parts.append(ext)
ob = W.join("PlugSocket", parts)
W.mark_sharp(ob, 40)
print("tris before finish", P.tris(ob))


def paint(Pm, Nm, base, orm, mask):
    """knurled bands (diamond cross-hatch), rubber insert ring with a dark centre (the plug's porcelain goes there)"""
    x, y, z = Pm[..., 0], Pm[..., 1], Pm[..., 2]
    r = np.hypot(x, y); a = np.arctan2(y, x)
    knurl = mask & (r > 0.033) & (r < 0.0352) & (((z > 0.556) & (z < 0.612)) | ((z > 0.754) & (z < 0.800)))
    u = a * 0.0345; p = 0.0085
    d1 = np.mod(u + z, p) / p; d2 = np.mod(u - z, p) / p
    cross = knurl & ((d1 < 0.28) | (d2 < 0.28))
    base[cross] = base[cross] * 0.55; orm[cross, 1] = 0.6
    # sleeve: fine rings
    sl = mask & (r > 0.0385) & (z > 0.632) & (z < 0.734)
    ring = sl & (np.mod((z - 0.632) / 0.0102, 1.0) < 0.22)
    base[ring] = base[ring] * 0.78
    # rubber floor: grey ring + black centre hole
    fl = mask & (np.abs(z - HEX_D) < 0.002) & (Nm[..., 2] < -0.5)
    base[fl & (r > 0.036)] = T.hexf("#2E2E31")
    base[fl & (r < 0.034)] = T.hexf("#0A0A0B")
    # drive hole floor: dark
    df = mask & (np.abs(z - (TOP - DRIVE_D)) < 0.002) & (Nm[..., 2] > 0.5)
    base[df] = T.hexf("#151517")
    # engraved size ring on the socket (no text)
    eng = mask & (np.abs(r - R_SOCK) < 0.002) & (np.abs(z - 0.27) < 0.0025)
    base[eng] = base[eng] * 0.6
    return base, orm


T.finish(ob, OUT, "PlugSocket", paint=paint, smooth=40)
data = {"tool": "Spark plug socket (3/8 in drive, 5/8 in thin wall, rubber insert) on a 6 in extension", "units": "stud",
        "space": "mesh local, Roblox axes (+Y = up toward the square drive, -Y = the socket mouth); origin = centre of the socket mouth",
        "Grip": {"pos": rb((0, 0, 0.683)), "axis": [0, 1, 0], "secondary_axis": [0, 0, -1],
                 "note": "the red sleeve (spinning the plug in / out by hand). Axis = up toward the drive end; the socket hangs below the fist. Round tool: SecondaryAxis is free."},
        "Drive": {"pos": rb((0, 0, TOP)), "axis": [0, 1, 0], "size": "3/8 in square (0.042 stud), female, 0.06 deep",
                  "seat": rb((0, 0, TOP - DRIVE_D)),
                  "note": "top face of the female square drive. To show it on a ratchet: put the ratchet's square-drive point (male, pointing down) on Drive with opposite axes; seat = where the male drive's end sits."},
        "Tip": {"pos": rb((0, 0, 0.025)), "axis": [0, -1, 0],
                "note": "where the plug's hex centre (F_SparkPlug_1, 0.025 above the hex bottom) sits inside the socket. Axis = out of the mouth (down into the plug well): align it with -(fastener axis)."},
        "Mouth": {"pos": rb((0, 0, 0)), "axis": [0, -1, 0], "hex_circumradius": R_HEX, "hex_depth": HEX_D},
        "Rubber_Insert": {"pos": rb((0, 0, HEX_D)), "note": "black rubber floor of the hex (grips the porcelain)"},
        "Turn_Axis": [0, 1, 0],
        "fit": "socket OD 0.125 (plug well 0.156), whole socket length 0.426 so the mouth reaches the plug hex 0.49 below the well top; the extension sticks 0.6 out of the well",
        "size": "1.10 long, socket OD 0.125, extension 0.065, sleeve 0.08, drive end 0.087"}
T.write_json(os.path.join(OUT, "plug_socket_attachments.json"), data, ob)
print("ok")
