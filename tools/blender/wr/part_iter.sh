#!/bin/sh
# wr-3d: build one part and render every review (grey, backface, colour, concept overlay, small sizes).
#   sh tools/blender/wr/part_iter.sh <part> <version> [palette.json]     (part = battery / radiator / muffler)
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
P_=$1; W="$ROOT/art/3d/$P_/work/$2"; CP="$ROOT/art/3d/$P_/work/concept/${4:-$P_}"
"$B" -b --factory-startup --python "$ROOT/tools/blender/wr/build_${5:-$P_}.py" -- "$W" "$3" 2>&1 | grep -E "tris|EXPORT|Error|Traceback|line [0-9]"
G=$(ls "$W"/*.glb | head -1)
"$B" -b --factory-startup --python "$ROOT/tools/blender/grey_views.py" -- "$G" "$W/grey" 1024 2>&1 | grep -E "Error"
py -I "$ROOT/tools/blender/grey_compare.py" "$W/grey" "$CP" "$W/grey_sheet.png" 300 >/dev/null
"$B" -b --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$G" "$W/backface" 2>&1 | grep Error
py -I "$ROOT/tools/blender/backface_count.py" "$W/backface" | awk '{s+=$2} END {print "backface px:", s}'
"$B" -b --factory-startup --python "$ROOT/tools/blender/review_views.py" -- "$G" "$W/colour" 1024 2>&1 | grep -E "TRIS|Error"
py -I "$ROOT/tools/blender/sheet_compare.py" "$W/colour" "$CP" "$W/colour_sheet.png" 400 >/dev/null
py -I "$ROOT/tools/blender/small_views.py" "$W/colour" "$W/small_views.png" >/dev/null
mkdir -p "$W/grey_named"; for v in front back left right top bottom; do cp "$W/grey/eevee_$v.png" "$W/grey_named/$v.png"; done
py -I "$ROOT/tools/blender/wr/compare_cells.py" "$CP" "$W/grey_named" "$W/overlay"
