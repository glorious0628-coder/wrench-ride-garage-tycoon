# Local 3D finishing (no 쫄병) — main 10-20 prototype, owner: pp-3d-make

User 10-20: "아니 쫄병이 시키지마", "쫄병이 너무 느려 3D 텍스쳐부터 PBR? 이것도 너희가 해".
Blender 5.2.2: `C:\Users\glori\Tools\blender-5.2.2\blender.exe --background --factory-startup --python <script> -- <args>`
(add-ons QRemeshify and StableGen are installed in the user profile; --factory-startup skips them — drop it to use them).

1. Shape: `py -I tools/split_6view.py <sheet> C:\Users\glori\ComfyUI\input\<name>` then
   `py -I tools/comfy_hunyuan3d.py <seed> <tag> "front=..,left=..,back=..,right=.."` → ComfyUI\output\mesh\<tag>_20k.glb
2. Reduce + UV + project the concept views + bake: `project_bake.py -- <20k.glb> <out_prefix> 1500 <views.json>`
   → <out>.glb (≤1,500 tris, UVs), <out>_proj.png (concept colours on the UVs), <out>_mask.png (UV coverage).
   views.json = each split view + the object's box in it (split_6view prints them), `power` (default 12) sharpens views.
3. Clean colours into materials + PBR maps: `py -I quantize_pbr.py <out>_proj.png <prefix> <palette.json> <out>_mask.png`
   → <prefix>_base.png, _orm.png (G roughness, B metal), _labels.png. palette = the item's real materials (hex from the
   concept, roughness/metal per real material — see material-per-object).
4. PBR GLB: `pbr_glb.py -- <out>.glb <prefix>_base.png <prefix>_orm.png <final>.glb`
Duck example: views/palette json here; result art/3d/trophy_duck/local_pbr_test/ (the eyes and bill edges are still rough).

## pp-3d-make additions (10-20, before the session reset)
- `tools/blender/clean_views.py <views.json> <palette.json> <out_dir>` — 2D clean of the split concept cells BEFORE
  projecting (flat material colours, painted highlights removed: pure-white specks V>0.95 and small white patches take
  the surrounding material; background = pure white >=252 connected to the border, filled with the nearest material so
  edges don't pick up white). Writes clean cells + a new views.json for project_bake.py. Sole-type white materials
  must be `"white": true` in the palette. Tested on the sneaker only.
- views.json boxes = the object's bbox inside each 600px split cell (non-white bbox of the cell), not the sheet coords
  split_6view prints.
- Use absolute paths for Blender outputs (relative paths in image.save land somewhere else).
- `notes/design/3d_tools/bl_retopo.py` — simple import→decimate→smart UV→height 1.8, bbox centre, turn +Z→−Z export.
- `notes/design/3d_tools/valuable_s2f.py` — texture-only edit of a box GLB (fits front-face UV ↔ studs, erases and
  re-places a decal, matches the roughness map, rewrites the GLB images without touching mesh/UV).
- project_bake/pbr_glb keep Hunyuan's +Z front: turn 180° about up before export for the game's −Z.

## pp-3d-make 10-20 afternoon: the working way (after the user's feedback)
User: "카메라도 매끈하지 않아", "회색 모델링을 먼저 매끈하게 하고, 그 다음에 색을 입히는 걸로 해", "부위 마다 시안의 색깔 코드 있잖아. 그걸로 해줭", "시안과 겹쳐서 하는 것 좋다!"
1. Shape from clean primitives, measured on the 6-view concept cells (224 px = 1 unit): `build_camera.py`, `build_alarm.py`, `build_duck.py`
   using `proc_lib.py` (rounded_box, cylinder, lathe, lathe_loop + rounded_rect_loop for even rings, lathe_cap, sweep for smooth
   strokes like clock hands / mouths, sphere/lump teardrops; finish(): hidden-face cull, delete loose, normals out, UV split at
   material borders, optional planar UV for painted parts, per-material bake to base + ORM, texture padding, pivot bottom centre).
   Hunyuan meshes were bumpy -> not used for these. Don't melt organic lumps (voxel grain / QRemeshify lost the wings).
2. Grey review first: `grey_views.py` (EEVEE raking light + Workbench back-face culling) + `grey_compare.py`, 2x crops, my own look,
   then API (`tools/api_image_review.py`). Back faces: `backface_views.py` (11 angles incl. 5 deg) + `backface_count.py` = 0.
3. Overlay with the concept at the same size: `notes/design/3d_tools/concept_compare.py <6view> <renders> <out>`.
4. Colour = measured concept codes per part: `part_colours.py` (label maps from `view_labels.py`).
5. Colour renders: `review_views.py`, `sheet_compare.py`, `small_views.py` (64/96 px).
Budget (main 10-20): display / held finds <= 5,000 tris; things placed many times (boxes, decorations, fences) <= 1,500.

## pp-3d-make 10-20: people (R15) and animals (block parts) — notes/design/3d_tools/r15_npc_plan.md
- People are the default blocky R15 + classic Shirt/Pants (585x559) + face Decal + MeshPart accessories. Underlay for the
  artist `tools/r15_underlay.py`, template tools `tools/r15_clothes.py` (guide / fitcheck / bake), preview render
  `tools/blender/r15_preview.py` (same 418x627 cells, 88 px/stud as the underlay) -> concept_compare.py.
- Dogs / cats: part boxes from the code, underlay `tools/block_underlay.py dog|cat`.
