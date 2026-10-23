#!/bin/sh
# Fault-look parts: build + every review image (wr-3d helper 10-21).   sh tools/blender/wr_fault/review.sh <version>
B="C:/Users/glori/Tools/blender-5.2.2/blender.exe"
ROOT="C:/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon"
T="$ROOT/tools/blender/wr_fault"; FP="$ROOT/art/3d/fault_parts"; W="$FP/work/$1"; CP="$FP/work/concept"; PAL="$FP/work/palette.json"
mkdir -p "$W"
"$B" -b --factory-startup --python "$T/build_tanks.py" -- "$W" coolant,brake "$PAL" 2>&1 | grep -E "TRIS|Error|Traceback"
"$B" -b --factory-startup --python "$T/build_wipers.py" -- "$W" "$PAL" 2>&1 | grep -E "pivot|TRIS|Error|Traceback"
"$B" -b --factory-startup --python "$T/build_nozzles.py" -- "$W" "$PAL" 2>&1 | grep -E "EXPORTED|Error|Traceback"
V6="front,back,left,right,top,bottom,threeq,threeq_back,threeq_left"
WV="dir:0/0/1:n_top,dir:0/0/-1:n_bottom,front,back,threeq,threeq_back,dir:0.3/1/0.6:hi3q"
COOL="$W/CoolantTank_Body.glb $W/CoolantTank_Cap.glb"; COOLL="$COOL $W/Deco_Level_Coolant.glb $W/Deco_Level_Coolant_Upper.glb"
BRK="$W/BrakeReservoir_Body.glb $W/BrakeReservoir_Base.glb $W/BrakeReservoir_Cap.glb"; BRKL="$BRK $W/Deco_Level_BrakeFluid.glb"
for m in grey colour; do
  "$B" -b --factory-startup --python "$T/part_views.py" -- "$W/cool_$m" $m 348 600 600 2.44 5.95 3.05 $V6 $([ $m = grey ] && echo $COOL || echo $COOLL) 2>&1 | grep Error
  "$B" -b --factory-startup --python "$T/part_views.py" -- "$W/brake_$m" $m 495 600 600 -1.55 4.72 3.08 $V6 $([ $m = grey ] && echo $BRK || echo $BRKL) 2>&1 | grep Error
  "$B" -b --factory-startup --python "$T/part_views.py" -- "$W/nozzle_$m" $m 1500 600 600 0 0 0.03 $V6 "$W/local_WasherNozzle.glb" 2>&1 | grep Error
  "$B" -b --factory-startup --python "$T/part_views.py" -- "$W/wiperL_$m" $m 128 520 300 1.42 -0.1 0.03 "$WV" "$W/local_WiperArm_Long.glb" "$W/local_WiperBlade_Long.glb" 2>&1 | grep Error
  "$B" -b --factory-startup --python "$T/part_views.py" -- "$W/wiperS_$m" $m 128 520 300 1.21 -0.07 0.03 "$WV" "$W/local_WiperArm_Short.glb" "$W/local_WiperBlade_Short.glb" 2>&1 | grep Error
done
"$B" -b --factory-startup --python "$T/part_views.py" -- "$W/wiperL_worn" colour 128 520 300 1.42 -0.1 0.03 "dir:0/0/1:n_top,hi3q,dir:0.2/0.6/-1:under" "$W/local_WiperArm_Long.glb" "$W/local_WiperBlade_Long_Worn.glb" 2>&1 | grep Error
# 2x grey close-ups (smoothness / round circles / gaps)
"$B" -b --factory-startup --python "$T/part_views.py" -- "$W/cool_grey2x" grey 700 900 900 2.44 5.89 3.0 threeq,threeq_back,threeq_left,bottom $COOL 2>&1 | grep Error
"$B" -b --factory-startup --python "$T/part_views.py" -- "$W/brake_grey2x" grey 990 900 900 -1.55 4.72 3.08 threeq,threeq_back,threeq_left,bottom $BRK 2>&1 | grep Error
"$B" -b --factory-startup --python "$T/part_views.py" -- "$W/wiper_grey2x" grey 420 1100 500 0.35 -0.12 0.05 "dir:0/0/1:n_top,front,hi3q,dir:-0.6/-1/0.5:back3q" "$W/local_WiperArm_Long.glb" "$W/local_WiperBlade_Long.glb" 2>&1 | grep Error
"$B" -b --factory-startup --python "$T/part_views.py" -- "$W/nozzle_grey2x" grey 2800 900 900 0 0 0.03 threeq,threeq_back,bottom,dir:0.4/-1/0.3:backlow "$W/local_WasherNozzle.glb" 2>&1 | grep Error
# back faces (11 directions) for every game GLB
rm -f "$W/backface_px.txt"
for g in CoolantTank_Body CoolantTank_Cap CoolantTank_OverflowHose Deco_Level_Coolant Deco_Level_Coolant_Upper BrakeReservoir_Body BrakeReservoir_Base BrakeReservoir_Cap Deco_Level_BrakeFluid WiperArm_Long WiperBlade_Long WiperArm_Short WiperBlade_Short Washer_Nozzle_L Washer_Nozzle_R; do
  "$B" -b --factory-startup --python "$ROOT/tools/blender/backface_views.py" -- "$W/$g.glb" "$W/backface/$g" 2>&1 | grep Error
  echo "$g $(py -I "$ROOT/tools/blender/backface_count.py" "$W/backface/$g" | awk '{s+=$2} END {print s}')" >> "$W/backface_px.txt"
done
cat "$W/backface_px.txt"
# same-scale overlays with the concepts
py -I "$T/overlay.py" "$CP/coolant_tank" "$W/cool_colour" "$W/ov_cool" 348 "coolant $1"
py -I "$T/overlay.py" "$CP/brake_reservoir" "$W/brake_colour" "$W/ov_brake" 495 "brake $1"
py -I "$T/overlay.py" "$CP/washer_nozzle" "$W/nozzle_colour" "$W/ov_nozzle" 1500 "nozzle $1"
py -I "$T/overlay.py" "$CP/wiper_long" "$W/wiperL_colour" "$W/ov_wiper" 128 "wiper long $1" "front=n_top,back=n_bottom,left=front,right=back,top=n_top,bottom=n_bottom" center
# fit on the car + in-place renders
"$B" -b --factory-startup --python "$T/fit_check.py" -- "$W/fit.json" $COOLL "$W/CoolantTank_OverflowHose.glb" $BRKL "$W/WiperArm_Long.glb" "$W/WiperBlade_Long.glb" "$W/WiperArm_Short.glb" "$W/WiperBlade_Short.glb" "$W/Washer_Nozzle_L.glb" "$W/Washer_Nozzle_R.glb" 2>&1 | grep -E "Error|Traceback"
py -I "$T/fit_summary.py" "$W/fit.json" > "$W/fit_summary.txt"; tail -5 "$W/fit_summary.txt"
"$B" -b --factory-startup --python "$T/inplace.py" -- "$W" "$W/inplace_ok" 3.10 3.20 workcam,coolant_close,brake_close,coolant_front 57.8 2>&1 | grep -E "Error|Traceback"
"$B" -b --factory-startup --python "$T/inplace.py" -- "$W" "$W/inplace_low" 2.66 2.97 workcam,coolant_close,brake_close,coolant_front 57.8 2>&1 | grep -E "Error|Traceback"
"$B" -b --factory-startup --python "$T/inplace.py" -- "$W" "$W/inplace_closed" 3.10 3.20 cowl_front,cowl_3q,cowl_driver,cowl_mid,nozzle_close 0 2>&1 | grep -E "Error|Traceback"
"$B" -b --factory-startup --python "$T/inplace.py" -- "$W" "$W/inplace_service" 3.10 3.20 cowl_front,cowl_3q 0 service 2>&1 | grep -E "Error|Traceback"
echo "review done $W"
