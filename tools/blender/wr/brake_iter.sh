#!/bin/sh
# wr-3d: build the brake set, assemble the review GLB (outboard = review front) and render grey + colour reviews.
#   sh tools/blender/wr/brake_iter.sh <version> [palette.json]
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
W="$ROOT/art/3d/brake/work/$1"
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr/build_brake.py" -- "$W" "$2" 2>&1 | grep -E "tris|EXPORT|Error|Traceback|line [0-9]|ok json|hidden"
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr/assemble.py" -- "$W/review_brake.glb" 90 "$W/Disc.glb" 0 0 0 "$W/CaliperBracket.glb" 0 0.46 0 "$W/Caliper.glb" 0 0.46 0 "$W/BrakePads.glb" 0 0.46 0 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$ROOT/tools/blender/grey_views.py" -- "$W/review_brake.glb" "$W/grey" 1024 2>&1 | grep -E "TRIS|Error"
py -I "$ROOT/tools/blender/grey_compare.py" "$W/grey" "$ROOT/art/3d/brake/work/concept/brake" "$W/grey_sheet.png" 300
"$B" --background --factory-startup --python "$ROOT/tools/blender/review_views.py" -- "$W/review_brake.glb" "$W/colour" 1024 2>&1 | grep -E "TRIS|Error"
py -I "$ROOT/tools/blender/sheet_compare.py" "$W/colour" "$ROOT/art/3d/brake/work/concept/brake" "$W/colour_sheet.png" 400
py -I "$ROOT/tools/blender/small_views.py" "$W/colour" "$W/small_views.png"
