#!/bin/sh
# wr-3d: build the wheel, assemble the review GLB (outboard = review front) and render grey views + grey sheet.
#   sh tools/blender/wr/wheel_iter.sh <version> [palette.json]
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
W="$ROOT/art/3d/wheel/work/$1"
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr/build_wheel.py" -- "$W" 48 40 "$2" 2>&1 | grep -E "tris|EXPORT|Error|Traceback|line [0-9]"
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr/assemble.py" -- "$W/review_wheel.glb" 90 "$W/Rim.glb" 0 0 0 "$W/Tire.glb" 0 0 0 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$ROOT/tools/blender/grey_views.py" -- "$W/review_wheel.glb" "$W/grey" 1024 2>&1 | grep -E "TRIS|Error"
py -I "$ROOT/tools/blender/grey_compare.py" "$W/grey" "$ROOT/art/3d/wheel/work/concept/wheel" "$W/grey_sheet.png" 300
# colour review (PBR renders, concept sheet, small in-game sizes)
"$B" --background --factory-startup --python "$ROOT/tools/blender/review_views.py" -- "$W/review_wheel.glb" "$W/colour" 1024 2>&1 | grep -E "TRIS|Error"
py -I "$ROOT/tools/blender/sheet_compare.py" "$W/colour" "$ROOT/art/3d/wheel/work/concept/wheel" "$W/colour_sheet.png" 400
py -I "$ROOT/tools/blender/small_views.py" "$W/colour" "$W/small_views.png"
