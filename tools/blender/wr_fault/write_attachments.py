# fault_parts_attachments.json from one review version (wr-3d helper 10-21).
#   py -I write_attachments.py <work/vN dir> <out.json>
import json, os, sys

W, OUTJ = sys.argv[1], sys.argv[2]
mi = json.load(open(os.path.join(W, "mesh_info.json"), encoding="utf-8"))
wf = json.load(open(os.path.join(W, "wiper_fit.json"), encoding="utf-8"))
nf = json.load(open(os.path.join(W, "nozzle_fit.json"), encoding="utf-8"))
fit = json.load(open(os.path.join(W, "fit.json"), encoding="utf-8")) if os.path.exists(os.path.join(W, "fit.json")) else {}
bf = {}
if os.path.exists(os.path.join(W, "backface_px.txt")):
    for ln in open(os.path.join(W, "backface_px.txt")):
        k, v = ln.split(); bf[k] = int(v)
M = lambda k: {kk: vv for kk, vv in (mi.get(k) or wf.get(k) or nf.get(k)).items() if kk in ("origin", "bbox_centre", "bbox_size", "tris")}
tris = {k: M(k)["tris"] for k in ["CoolantTank_Body", "CoolantTank_Cap", "CoolantTank_OverflowHose", "Deco_Level_Coolant", "Deco_Level_Coolant_Upper",
                                  "BrakeReservoir_Body", "BrakeReservoir_Base", "BrakeReservoir_Cap", "Deco_Level_BrakeFluid",
                                  "WiperArm_Long", "WiperBlade_Long", "WiperArm_Short", "WiperBlade_Short", "Washer_Nozzle_L", "Washer_Nozzle_R"]}
L, S = wf["fit_Long"], wf["fit_Short"]
J = {
 "what": "fault-look parts for the engine-bay / windshield Work View (fault_looks v0.3 §5b + wr-carbook notes/research/car_knowledge/fault_looks_3d_check.md, 10-21)",
 "units": "stud (1 stud = 0.28 m)",
 "coords": "car-local Roblox: +X = car right (passenger), +Y up, -Z = car front, origin = ground between the axles (car_spec §0). Every GLB "
           "mesh is already at its car place (rest pose); each node's origin = its pivot (listed). A MeshPart imported from it is centred on "
           "its bounds: a point P on that part = P - bbox_centre (in the part's space, no rotation).",
 "files": {"CoolantTank.glb": ["CoolantTank_Body", "CoolantTank_Cap", "CoolantTank_OverflowHose", "Deco_Level_Coolant", "Deco_Level_Coolant_Upper"],
           "BrakeReservoir.glb": ["BrakeReservoir_Body", "BrakeReservoir_Base", "BrakeReservoir_Cap", "Deco_Level_BrakeFluid"],
           "Wipers.glb": ["WiperArm_Long", "WiperBlade_Long", "WiperArm_Short", "WiperBlade_Short"],
           "WiperBlades_Worn.glb": ["WiperBlade_Long_Worn", "WiperBlade_Short_Worn"],
           "WasherNozzles.glb": ["Washer_Nozzle_L", "Washer_Nozzle_R"],
           "meshes/": "the same meshes one GLB each (+ WasherNozzle.glb upright at the origin)"},
 "CoolantTank": {
  "meshes": {k: M(k) for k in ("CoolantTank_Body", "CoolantTank_Cap", "CoolantTank_OverflowHose", "Deco_Level_Coolant", "Deco_Level_Coolant_Upper")},
  "body": {"see_through": True, "MeshPart_Transparency": 0.45, "colour": "#E6E4EC milky white (concept)",
           "shape": "tall box X 2.12..2.86, Y 2.45..3.48, Z -6.20..-5.58; the outboard LOWER corner (X > 2.53, Y < 2.88) is cut away = the "
                    "front wheel house sits there (liner wall X 2.57, arch roof Y 2.45..2.84 under the tank)",
           "origin": "bottom centre (2.49, 2.45, -5.89)"},
  "Fluid_Coolant_cap_top": [2.55, 3.585, -5.75],
  "cap": {"type": "black FLIP-UP cap (Camry; not a twist cap)", "hinge": M("CoolantTank_Cap")["origin"], "axis": [1, 0, 0], "open_deg": 105,
          "rule": "open: rotate +open_deg about +X through the hinge (front edge with the latch tab goes up); latch tab at the front edge",
          "overflow_hose": "CoolantTank_OverflowHose starts at the nipple on the cap top; turn it with the cap (same hinge) or leave it - it is a soft hose"},
  "overflow_hose_end": [2.175, 3.06, -6.48],
  "lines": {"F": 3.40, "L": 3.00, "note": "wr-carbook #4 (F just under the shoulder, L mid side); fault_looks §5b had F 3.30 / L 2.80. Raised dash + painted letter on the FRONT face (-Z)"},
  "liquid": {"colour": "#E59AB8 rose pink (carbook #5; §5b #CCB1C2 read grey through the white tank)", "rest_top_in_file": 3.40,
             "parts": {"Deco_Level_Coolant": {"bottom": 2.495, "top_max": 2.925, "what": "inboard lower column (the narrow part)"},
                       "Deco_Level_Coolant_Upper": {"bottom": 2.925, "what": "full-width upper part, only when level > 2.925"}},
             "level_range": [2.60, 3.45], "empty": 2.60, "overflow": 3.45,
             "rule": "level h: lower.Size.Y = clamp(h, 2.50, 2.925) - 2.495 (bottom fixed at 2.495); upper visible only if h > 2.93: Size.Y = h - 2.925 "
                     "(bottom fixed at 2.925). Both are straight prisms: scaling Y never bends the shape",
             "why_two": "the tank is narrower below Y 2.88 (wheel house), one prism cannot fill both"},
  "hose_nipple_bottom": {"tip": [1.962, 2.58, -5.80], "axis": [-1, 0, 0], "note": "concept's bottom outlet (inboard side)"}},
 "BrakeReservoir": {
  "meshes": {k: M(k) for k in ("BrakeReservoir_Body", "BrakeReservoir_Base", "BrakeReservoir_Cap", "Deco_Level_BrakeFluid")},
  "body": {"see_through": True, "MeshPart_Transparency": 0.45, "colour": "#E8E6DF", "box": "X -1.895..-1.205, Y 2.885..3.335, Z -4.935..-4.505",
           "origin": "bottom centre (-1.55, 2.885, -4.72)"},
  "base": "opaque black plate + 2 grommets / outlet tips (along the master cylinder, Z -4.84 / -4.60) + level-sensor connector on the -X side",
  "Fluid_BrakeFluid_cap_top": [-1.55, 3.43, -4.72],
  "cap": {"type": "WHITE twist cap (carbook #1; §5b said black, concept yellow)", "origin": M("BrakeReservoir_Cap")["origin"], "axis": [0, 1, 0],
          "rule": "unscrew = rotate about +Y (positive = counter-clockwise seen from above) and lift"},
  "lines": {"MAX": 3.28, "MIN": 3.02},
  "liquid": {"name": "Deco_Level_BrakeFluid", "bottom": 2.925, "level_range": [2.93, 3.32], "rest_top_in_file": 3.15,
             "colours": {"new": "#E9C766 light amber", "old": "#8A5A2E brown"}, "rule": "Size.Y = h - 2.925, bottom fixed; plain colour -> MeshPart.Color"},
  "master_cylinder": "decor master_cyl (Deco_EngineBay, centre Y 2.95, top 3.07) must go 0.235 lower (centre 2.715, top 2.835 = base bottom): with the "
                     "§5b MIN 3.02 the tank bottom has to be at 2.885"},
 "Wipers": {
  "rule": "meshes are in the REST pose. Sweep / service: rotate arm + blade together about sweep_axis through pivot (right-handed, degrees). "
          "Lift (off the glass): rotate arm + blade about lift_axis through lift_hinge, positive = away from the glass. Blade swap: the blade's "
          "own origin = middle of the rubber edge; adapter_top = where the arm hook sits",
  "Long": {"blade_length": 2.7, "side": "driver (26 in)", "pivot": L["pivot"], "sweep_axis": L["n_glass_normal"], "blade_dir": L["u_blade_dir"],
           "blade_mid_rubber_edge": L["blade_mid_rubber_edge"], "service_deg": L["service_deg"], "lift_hinge": L["lift_hinge"], "lift_axis": L["lift_axis"],
           "lift_deg_for_0p4": L["lift_deg"], "blade_bend": L["blade_bend_sag"], "rubber_to_glass_gap": [L["rubber_gap_min"], L["rubber_gap_max"]]},
  "Short": {"blade_length": 2.1, "side": "passenger (20 in, carbook #9; §5b said 1.9)", "pivot": S["pivot"], "sweep_axis": S["n_glass_normal"],
            "blade_dir": S["u_blade_dir"], "blade_mid_rubber_edge": S["blade_mid_rubber_edge"], "service_deg": S["service_deg"], "lift_hinge": S["lift_hinge"],
            "lift_axis": S["lift_axis"], "lift_deg_for_0p4": S["lift_deg"], "blade_bend": S["blade_bend_sag"],
            "rubber_to_glass_gap": [S["rubber_gap_min"], S["rubber_gap_max"]]},
  "meshes": {k: M(k) for k in ("WiperArm_Long", "WiperBlade_Long", "WiperArm_Short", "WiperBlade_Short")},
  "worn": "WiperBlade_*_Worn = same mesh, cracked / chalky rubber texture (swap the MeshPart or its SurfaceAppearance)",
  "pivot_note": "§5b pivot Z -3.55 is ON the glass (glass bottom edge = Z -3.77) -> pivots at Z -3.80 on the cowl / glass seam. They cannot sit "
                "further forward: the hood's rear edge (Z -4.06) swings up through the cowl when the hood opens (checked 0..58 deg: no hit). "
                "The real 'hidden under the hood edge' rest spot does not exist on this body (hood rear edge is flush with the cowl)"},
 "WasherNozzles": {
  "on": "Hood (weld to the hood, they open with it)", "mesh": "same mesh both sides, tilted to the hood surface",
  "L": {k: nf["Washer_Nozzle_L"][k] for k in ("base_on_hood", "hood_top", "sink_into_hood", "jet_tip", "jet_dir", "fan_width_deg", "glass_target", "tilt_deg")},
  "R": {k: nf["Washer_Nozzle_R"][k] for k in ("base_on_hood", "hood_top", "sink_into_hood", "jet_tip", "jet_dir", "fan_width_deg", "glass_target", "tilt_deg")},
  "spray": "one wide fan per nozzle (about 25 deg), starts at jet_tip going jet_dir (30 deg up), lands around glass_target "
           "(~1.05 stud up the glass from its bottom edge); the two fans overlap a little in the middle (carbook #7)",
  "place_note": "carbook #6: just in front of the hood's rear edge, half sunk -> Z -4.20 (rear edge Z -4.06), base 0.035 below the hood top",
  "meshes": {k: M(k) for k in ("Washer_Nozzle_L", "Washer_Nozzle_R")}},
 "decor_changes_needed (Deco_EngineBay, wr-3d-body / main)": [
  "remove the old coolant_tank + coolant_cap and brake_res + brake_cap boxes (these GLBs replace them)",
  "coolant_hose: drop its first piece (tank end, Z > -6.45); CoolantTank_OverflowHose ends at (2.175, 3.06, -6.48) where the rest continues to the radiator neck",
  "master_cyl: centre Y 2.95 -> 2.715 (top 2.835) so the reservoir base sits on it",
  "washer tank body (2.60, 2.79, -6.60, top 3.165) hides the coolant tank's lower half (L line) from the Work View camera: §5b says the body is "
  "behind the bumper - keep only the filler neck + cap in the bay",
  "harness at Y 3.25, Z -5.03 runs right in front of the brake reservoir's MAX line - drop it to ~Y 2.9 or route it behind",
  "washer cap: Camry = BLACK cap with an embossed windshield/spray icon (carbook #2) - decor still has a blue cap"],
 "triangles": {**tris, "total": sum(tris.values())},
 "backface_px_11_views": bf,
 "fit_check": {"liquid_inside": fit.get("liquid_inside"), "hood_sweep_hits_0_58deg": fit.get("hood_sweep_hits")},
}
json.dump(J, open(OUTJ, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print("ok", OUTJ, J["triangles"]["total"])
