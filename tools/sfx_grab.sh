#!/bin/sh
# grab.sh <prefix = first 20 chars of the prompt, punctuation dropped, spaces -> _> <key> <offset>: Downloads/<prefix>_#N-*.wav -> art/sfx/raw/<key>_<N+offset>.wav
# grab.sh <prefix20> <key> <offset>
RAW="/c/Users/glori/Documents/Roblox/Wrench & Ride Garage Tycoon/art/sfx/raw"
for f in /c/Users/glori/Downloads/"$1"_#*.wav; do
  [ -e "$f" ] || continue
  n=$(basename "$f" | sed -E 's/.*_#([0-9]+)-.*/\1/')
  mv "$f" "$RAW/$2_$((n+$3)).wav" && echo "$2_$((n+$3))"
done
