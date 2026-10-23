#!/bin/sh
# wr 3D helper 10-22: renders for one tools_v2 tool (colour 8 views, grey, back faces, concept sheet, small sizes).
#   sh tools/blender/wr/tools_v2/review_tool.sh <tool_dir_name> <Glb> <concept_name> [build_script]
#   e.g. sh .../review_tool.sh fuse_puller FusePuller fuse_puller build_fuse_puller.py
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
D="$ROOT/art/3d/tools_v2/$1"; G="$D/$2.glb"; W="$ROOT/art/3d/tools_v2/work/$1"; CP="$ROOT/art/3d/tools_v2/work/concept/$3"
mkdir -p "$W"
if [ -n "$4" ]; then
  "$B" -b --factory-startup --python "$ROOT/tools/blender/wr/tools_v2/$4" -- "$D" 2>&1 | grep -E "tris|EXPORT|RIG|Error|Traceback|line [0-9]"
fi
"$B" -b --factory-startup --python "$ROOT/tools/blender/review_views.py" -- "$G" "$W/colour" 1024 2>&1 | grep -E "TRIS|Error"
"$B" -b --factory-startup --python "$ROOT/tools/blender/grey_views.py" -- "$G" "$W/grey" 1024 2>&1 | grep -E "Error"
"$B" -b --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$G" "$W/backface" 2>&1 | grep Error
py -I "$ROOT/tools/blender/backface_count.py" "$W/backface" | awk '{s+=$2} END {print "backface px:", s}'
py -I "$ROOT/tools/blender/sheet_compare.py" "$W/colour" "$CP" "$W/colour_sheet.png" 400 >/dev/null
py -I "$ROOT/tools/blender/small_views.py" "$W/colour" "$W/small_views.png" >/dev/null
echo done "$1"
