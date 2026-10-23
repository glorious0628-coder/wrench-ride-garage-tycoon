#!/bin/sh
# SUV engine bay + underbody decor (wr-3d-suv 2nd pass): needs colour.sh first (work/B/suv_body.blend + col_prev GLBs).
# decor build + checks -> PBR bake into art/3d/suv_body/decor -> back faces -> review scenes (hood on the prop rod /
# closed for the lift) -> renders (colour + grey) -> sheets (review2_sheets_suv.py).
#   sh tools/blender/wr_suv/decor.sh
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -W 2>/dev/null || pwd)"
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
S="$ROOT/tools/blender/wr_suv"
W="$ROOT/art/3d/suv_body/work/B"
WD="$ROOT/art/3d/suv_body/work/decor"
D="$ROOT/art/3d/suv_body/decor"
BC="$ROOT/art/3d/suv_body/B_concept"
mkdir -p "$D" "$WD/col_prev"
"$B" --background --factory-startup --python "$S/build_decor_suv.py" -- "$W/suv_body.blend" "$WD" 2>&1 | grep -E "Error|Traceback|ROD|DECOR DONE"
"$B" --background --factory-startup --python "$S/colour_suv.py" -- "$WD/suv_decor.blend" "$D" "$WD/col_prev" \
  "Deco_EngineTop:1024,Deco_EngineLower:1024,Deco_Transaxle:512,Deco_EngineBay:1024,Deco_FrontSubframe:512,Deco_Underbody:1024,Deco_RearAxle:512,HoodProp:256" \
  suv_decor_all 61 2>&1 | grep -E "Error|Traceback|COLOUR"
cp "$WD/decor_attachments.json" "$WD/decor_check.json" "$WD/hood_prop_attachments.json" "$D/"
rm -rf "$WD/bf"
for n in deco_enginetop deco_enginelower deco_transaxle deco_enginebay deco_frontsubframe deco_underbody deco_rearaxle hoodprop; do
  "$B" --background --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$D/suv_$n.glb" "$WD/bf/$n" >/dev/null 2>&1
  echo "$n backface_views 11 px: $(py -I "$ROOT/tools/blender/backface_count.py" "$WD/bf/$n" | awk '{s+=$2} END {print s}')"
done
"$B" --background --factory-startup --python "$S/place_others_suv.py" -- "$ROOT/art/3d" "$WD/review_others.glb" 2>&1 | grep -E "Error|PLACED"
SET="$W/col_prev/suv_body_all.glb;$WD/col_prev/suv_decor_all.glb;$WD/review_others.glb;$W/review_wheels.glb"
"$B" --background --factory-startup --python "$S/bay_scene_suv.py" -- "$BC/hood_attachments.json" "$D/hood_prop_attachments.json" "$WD/bay_open.blend" "$SET" 2>&1 | grep -E "Error|Traceback|saved"
"$B" --background --factory-startup --python "$S/bay_scene_suv.py" -- "$BC/hood_attachments.json" "$D/hood_prop_attachments.json" "$WD/lift.blend" "$SET;$WD/review_placeholders_under.glb" closed 2>&1 | grep -E "Error|Traceback|saved"
rm -rf "$WD/c_bay" "$WD/g_bay" "$WD/c_under" "$WD/g_under" "$WD/bf_ctx"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/bay_open.blend" "$WD/c_bay" 100 keep hero,bay_34,bay_top,prop_side,threeq_fl 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/bay_open.blend" "$WD/g_bay" 100 grey bay_top,bay_top2x,bay_34 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/lift.blend" "$WD/c_under" 100 keep under_front,under_rear,under_side,bottom under 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/lift.blend" "$WD/g_under" 100 grey under_front,under_rear,under_side under 2>&1 | grep -E "Error|Traceback"
# back faces in context: OUR deliverables only (B_concept body + decor GLBs; the review wheels are mirrored copies and the
# other helpers' parts are theirs), hood on the prop / closed, bay and lift views
SETD="$BC/suv_body_all.glb;$D/suv_decor_all.glb"
"$B" --background --factory-startup --python "$S/bay_scene_suv.py" -- "$BC/hood_attachments.json" "$D/hood_prop_attachments.json" "$WD/bf_open.blend" "$SETD" 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/bay_scene_suv.py" -- "$BC/hood_attachments.json" "$D/hood_prop_attachments.json" "$WD/bf_lift.blend" "$SETD" closed 2>&1 | grep -E "Error|Traceback"
rm -rf "$WD/bf_ours"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/bf_open.blend" "$WD/bf_ours" 100 bf hero,bay_34,bay_top,prop_side,front,left,threeq_fl 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$WD/bf_lift.blend" "$WD/bf_ours/lift" 100 bf under_front,under_rear,under_side,bottom,left,right,back 2>&1 | grep -E "Error|Traceback"
echo "context 14 views back-face px (body + decor, hood on prop / closed): $(py -I "$ROOT/tools/blender/backface_count.py" "$WD/bf_ours" | awk '{s+=$2} END {print s}') + $(py -I "$ROOT/tools/blender/backface_count.py" "$WD/bf_ours/lift" | awk '{s+=$2} END {print s}')"
py -I "$S/review2_sheets_suv.py" "$ROOT/art/3d/suv_body" "$ROOT/art/concepts/car_suv/suv_hero.png"
echo DECOR PASS DONE
