# print the measured default paint hex (wr-3d-suv): py -I paint_hex.py <colours.json>
import sys, json
print(json.load(open(sys.argv[1]))["paint"]["hex"])
