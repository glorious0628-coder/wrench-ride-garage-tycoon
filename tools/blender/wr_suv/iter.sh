#!/bin/sh
# quick iteration (wr-3d-suv): build variant, grey renders, concept compare.  sh tools/blender/wr_suv/iter.sh <A|B> [px=60] [build=1]
V=$1; PX=${2:-60}; BUILD=${3:-1}
ROOT="$(cd "$(dirname "$0")/../../.." && pwd -W 2>/dev/null || pwd)"
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
W="$ROOT/art/3d/suv_body/work/$V"
if [ "$BUILD" = "1" ]; then
  "$B" --background --factory-startup --python "$ROOT/tools/blender/wr_suv/build_suv.py" -- $V "$W" 2>&1 | grep -E "Error|Traceback|ALL DONE|CLOSED"
fi
"$B" --background --factory-startup --python "$ROOT/tools/blender/wr_suv/render_suv.py" -- "$W/glb/suv_body_all.glb;$W/review_wheels.glb" "$W/r" $PX grey all 2>&1 | grep -E "Error|Traceback"
py -I "$ROOT/tools/blender/wr_suv/compare_suv.py" "$ROOT/art/3d/suv_body/work/concept/suv" "$W/r" $PX "$W/cmp" $V
