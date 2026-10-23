#!/bin/sh
# wr-3d 10-21: all review images for the final Detail / Lite wheel + brake (2.75 size) and the 2.4 copy.
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
WW="$ROOT/art/3d/wheel/work/final275"; BB="$ROOT/art/3d/brake/work/final275"; R="$BB/review"; mkdir -p "$R"
W4="$ROOT/art/3d/wheel/work/final240"; B4="$ROOT/art/3d/brake/work/final240"
C=0.5270833
AS="$ROOT/tools/blender/wr/assemble.py"
"$B" -b --factory-startup --python "$AS" -- "$R/corner_detail.glb" 90 "$WW/Rim.glb" 0 0 0 "$WW/Tire.glb" 0 0 0 "$BB/Disc.glb" 0 0 0 "$BB/CaliperBracket.glb" 0 $C 0 "$BB/Caliper.glb" 0 $C 0 "$BB/BrakePads.glb" 0 $C 0 "$BB/Hub.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/corner_lite.glb" 90 "$WW/Rim_Lite.glb" 0 0 0 "$WW/Tire_Lite.glb" 0 0 0 "$BB/Brake_Lite.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/wheel_detail.glb" 90 "$WW/Rim.glb" 0 0 0 "$WW/Tire.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/wheel_lite.glb" 90 "$WW/Rim_Lite.glb" 0 0 0 "$WW/Tire_Lite.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/brake_detail.glb" 90 "$BB/Disc.glb" 0 0 0 "$BB/CaliperBracket.glb" 0 $C 0 "$BB/Caliper.glb" 0 $C 0 "$BB/BrakePads.glb" 0 $C 0 "$BB/Hub.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/brake_lite.glb" 90 "$BB/Brake_Lite.glb" 0 0 0 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/left_all.glb" -90 "$BB/Disc.glb" 0 0 0 "$BB/CaliperBracket_L.glb" 0 $C 0 "$BB/Caliper_L.glb" 0 $C 0 "$BB/BrakePads_L.glb" 0 $C 0 "$BB/Hub_L.glb" 0 0 0 "$BB/Brake_Lite_L.glb" 0 0 2.3 >/dev/null 2>&1
"$B" -b --factory-startup --python "$AS" -- "$R/corner_detail_240.glb" 90 "$W4/Rim.glb" 0 0 0 "$W4/Tire.glb" 0 0 0 "$B4/Disc.glb" 0 0 0 "$B4/CaliperBracket.glb" 0 0.46 0 "$B4/Caliper.glb" 0 0.46 0 "$B4/BrakePads.glb" 0 0.46 0 >/dev/null 2>&1
for N in corner_detail corner_lite wheel_detail wheel_lite brake_detail brake_lite left_all; do sh "$ROOT/tools/blender/wr/lod_review.sh" "$R" $N; done
"$B" -b --factory-startup --python "$ROOT/tools/blender/wr/compare_render.py" -- persp "$R/dist" "$R/corner_detail.glb" 1.375 "$R/corner_lite.glb" 1.375 3 8 20 >/dev/null 2>&1
"$B" -b --factory-startup --python "$ROOT/tools/blender/wr/compare_render.py" -- ortho "$R/size" "$R/corner_detail_240.glb" 1.2 "$R/corner_detail.glb" 1.375 >/dev/null 2>&1
for N in wheel_detail brake_detail; do mkdir -p "$R/${N}_named"; for v in front back left right top bottom; do cp "$R/${N}_grey/eevee_$v.png" "$R/${N}_named/$v.png"; done; done
py -I "$ROOT/tools/3d_check/concept_compare.py" "$ROOT/art/concepts/parts/wheel_6view.png" "$R/wheel_detail_named" "$R/overlay_wheel" | sed 's/^/wheel /'
py -I "$ROOT/tools/3d_check/concept_compare.py" "$ROOT/art/concepts/parts/brake_6view.png" "$R/brake_detail_named" "$R/overlay_brake" | sed 's/^/brake /'
py -I "$ROOT/tools/blender/sheet_compare.py" "$R/wheel_detail_colour" "$ROOT/art/3d/wheel/work/concept/wheel" "$R/wheel_colour_sheet.png" 400 >/dev/null
py -I "$ROOT/tools/blender/sheet_compare.py" "$R/brake_detail_colour" "$ROOT/art/3d/brake/work/concept/brake" "$R/brake_colour_sheet.png" 400 >/dev/null
py -I "$ROOT/tools/blender/small_views.py" "$R/corner_detail_colour" "$R/small_detail.png" >/dev/null
py -I "$ROOT/tools/blender/small_views.py" "$R/corner_lite_colour" "$R/small_lite.png" >/dev/null
echo done
