#!/bin/sh
# Full grey pass (wr-3d-suv): build A and B, renders (100 px/stud), concept compare, 2x zoom, hood-open hero, back-face
# checks (own 10 views + tools/blender/backface_views.py 11 views per GLB), measure, review sheets, deliverables.
#   sh tools/blender/wr_suv/final.sh
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -W 2>/dev/null || pwd)"
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
S="$ROOT/tools/blender/wr_suv"
for V in ${VARIANTS:-A B}; do
  W="$ROOT/art/3d/suv_body/work/$V"
  "$B" --background --factory-startup --python "$S/build_suv.py" -- $V "$W" 2>&1 | grep -E "Error|Traceback|ALL DONE|CLOSED"
  "$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/glb/suv_body_all.glb;$W/review_wheels.glb" "$W/r" 100 grey all 2>&1 | grep -E "Error|Traceback"
  "$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/glb/suv_body_all.glb;$W/review_wheels.glb" "$W/rh" 100 grey hero 2>&1 | grep -E "Error|Traceback"
  "$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/review_hood_open.glb;$W/review_wheels.glb" "$W/ropen" 100 grey hero,threeq_fl 2>&1 | grep -E "Error|Traceback"
  py -I "$S/compare_suv.py" "$ROOT/art/3d/suv_body/work/concept/suv" "$W/r" 100 "$W/cmp" $V | grep IoU
  sh "$S/zoom2x.sh" $V "$W/zoom2x.png"
  rm -rf "$W/bf_mine" "$W/bf"
  "$B" --background --factory-startup --python "$S/render_suv.py" -- "$W/glb/suv_body_all.glb" "$W/bf_mine" 100 bf all 2>&1 | grep -E "Error|Traceback"
  echo "$V own 10 views back-face px: $(py -I "$ROOT/tools/blender/backface_count.py" "$W/bf_mine" | awk '{s+=$2} END {print s}')"
  for n in shell glass hood bumper_f bumper_r chassis; do
    "$B" --background --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$W/glb/suv_$n.glb" "$W/bf/$n" >/dev/null 2>&1
    echo "$V $n backface_views 11 px: $(py -I "$ROOT/tools/blender/backface_count.py" "$W/bf/$n" | awk '{s+=$2} END {print s}')"
  done
  "$B" --background --factory-startup --python "$S/measure_suv.py" -- "$W/glb" "$W/measure.json" 2>&1 | grep -E "^\{"
done
[ -n "$NO_DELIVER" ] || true
py -I "$S/review_sheets_suv.py" "$ROOT/art/3d/suv_body/work" "$ROOT/art/3d/suv_body/review" "$ROOT/art/concepts/car_suv/suv_hero.png"
[ -n "$NO_DELIVER" ] && { echo FINAL DONE; exit 0; }
for V in A B; do
  W="$ROOT/art/3d/suv_body/work/$V"
  [ $V = A ] && D="$ROOT/art/3d/suv_body/A_spec" || D="$ROOT/art/3d/suv_body/B_concept"
  mkdir -p "$D"
  cp "$W"/glb/*.glb "$D/"
  cp "$W"/attachments/*.json "$D/"
  cp "$W/hood_check.json" "$D/hood_check.json"
  cp "$W/stats.json" "$D/suv_body_stats.json"
  cp "$W/measure.json" "$D/suv_body_measure.json"
done
echo FINAL DONE
