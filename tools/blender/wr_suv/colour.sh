#!/bin/sh
# Colour pass (wr-3d-suv): build B (slots) -> bake PBR + maps into B_concept -> checks -> renders -> sheets.
#   sh tools/blender/wr_suv/colour.sh
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -W 2>/dev/null || pwd)"
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
S="$ROOT/tools/blender/wr_suv"
W="$ROOT/art/3d/suv_body/work/B"
D="$ROOT/art/3d/suv_body/B_concept"
PAINT=$(py -I "$S/paint_hex.py" "$ROOT/art/3d/suv_body/work/colours.json")
"$B" --background --factory-startup --python "$S/build_suv.py" -- B "$W" 2>&1 | grep -E "Error|Traceback|ALL DONE|CLOSED"
mkdir -p "$D" "$W/col_prev"
"$B" --background --factory-startup --python "$S/colour_suv.py" -- "$W/suv_body_slots.blend" "$D" "$W/col_prev" 2>&1 | grep -E "Error|Traceback|COLOUR"
cp "$W"/attachments/*.json "$D/"; cp "$W/hood_check.json" "$D/hood_check.json"; cp "$W/stats.json" "$D/suv_body_stats.json"
"$B" --background --factory-startup --python "$S/measure_suv.py" -- "$D" "$W/measure.json" 2>&1 | grep -E "^\{"
cp "$W/measure.json" "$D/suv_body_measure.json"
rm -rf "$W/col_bf" "$W/col_bf_mine"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$D/suv_body_all.glb" "$W/col_bf_mine" 100 bf all 2>&1 | grep -E "Error|Traceback"
echo "own 10 views back-face px: $(py -I "$ROOT/tools/blender/backface_count.py" "$W/col_bf_mine" | awk '{s+=$2} END {print s}')"
for n in shell glass hood bumper_f bumper_r chassis; do
  "$B" --background --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$D/suv_$n.glb" "$W/col_bf/$n" >/dev/null 2>&1
  echo "$n backface_views 11 px: $(py -I "$ROOT/tools/blender/backface_count.py" "$W/col_bf/$n" | awk '{s+=$2} END {print s}')"
done
"$B" --background --factory-startup --python "$S/open_hood_scene.py" -- "$D/hood_attachments.json" "$W/col_open.blend" "$W/col_prev/suv_body_all.glb;$W/review_wheels.glb" 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/col_prev/suv_body_all.glb;$W/review_wheels.glb" "$W/col_r" 100 keep all 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/col_prev/suv_body_all.glb;$W/review_wheels.glb" "$W/col_r" 100 keep hero,sq_fl,sq_rr 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/col_open.blend" "$W/col_open" 100 keep hero,threeq_fl 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$D/suv_body_all.glb;$W/review_wheels.glb" "$W/col_neutral" 60 keep threeq_fl,threeq_rr 2>&1 | grep -E "Error|Traceback"
"$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/col_prev/suv_body_all.glb;$W/review_wheels.glb" "$W/col_r2" 200 keep threeq_fl,threeq_rr,left 2>&1 | grep -E "Error|Traceback"
py -I "$S/compare_suv.py" "$ROOT/art/3d/suv_body/work/concept/suv" "$W/col_r" 100 "$W/col_cmp" "B colour" | grep IoU
mkdir -p "$W/col_small"; cp "$W/col_r/sq_fl.png" "$W/col_small/threeq.png"; cp "$W/col_r/sq_rr.png" "$W/col_small/threeq_back.png"
py -I "$ROOT/tools/blender/small_views.py" "$W/col_small" "$W/col_small/small.png"
py -I "$S/zoom_crops.py" "$W/col_r2" "$W/col_zoom2x.png"
py -I "$S/colour_sheets_suv.py" "$W" "$ROOT/art/3d/suv_body/review" "$ROOT/art/concepts/car_suv/suv_hero.png" "$D" "$PAINT"
echo COLOUR PASS DONE
