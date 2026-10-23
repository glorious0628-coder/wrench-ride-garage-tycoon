# Thumbnail framing preview (wr-builder, 10-22): crop one wide Studio capture to the 16:9 band a target FOV would see.
# Capture once with the client Camera.FieldOfView = fov_cap (e.g. 81.8) and the final eye / look_at, then
#   py -I tools/builder/thumb_preview_crop.py <capture.jpg> <fov_cap> <fov_target> <out.jpg>
# to judge the composition before shooting the 6 stitch tiles (thumb_stitch.py).
import math
import sys

import cv2

src, fov_cap, fov_t, out = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4]
img = cv2.imread(src)
h, w = img.shape[:2]
f = (h / 2) / math.tan(math.radians(fov_cap) / 2)
hh = f * math.tan(math.radians(fov_t) / 2)
hw = hh * 16 / 9
x0, x1, y0, y1 = int(w / 2 - hw), int(w / 2 + hw), int(h / 2 - hh), int(h / 2 + hh)
print("img", w, h, "crop", x0, x1, y0, y1, "(cut)" if x0 < 0 or y0 < 0 else "")
cv2.imwrite(out, img[max(0, y0):min(h, y1), max(0, x0):min(w, x1)])
