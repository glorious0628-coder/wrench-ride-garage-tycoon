#!/bin/sh
# wr-3d: review one assembled GLB: grey views, back-face count, colour views.  sh lod_review.sh <dir> <name>
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
D="$1"; N="$2"
"$B" --background --factory-startup --python "$ROOT/tools/blender/grey_views.py" -- "$D/$N.glb" "$D/${N}_grey" 1024 2>&1 | grep -E "TRIS|Error"
"$B" --background --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$D/$N.glb" "$D/${N}_backface" 2>&1 | grep Error
py -I "$ROOT/tools/blender/backface_count.py" "$D/${N}_backface" | awk -v n="$N" '{s+=$2} END {print n, "backface px:", s}'
"$B" --background --factory-startup --python "$ROOT/tools/blender/review_views.py" -- "$D/$N.glb" "$D/${N}_colour" 1024 2>&1 | grep -E "Error"
