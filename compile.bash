#!/usr/bin/env bash

# Fail on error code, unknown var, and propagate errors from pipes:
set -veuo pipefail

# Move to location of this script
SCRIPT_DIR="$(realpath "$(dirname "$0")")"
cd "$SCRIPT_DIR"

mkdir -p out

note="Paper: Clairefontaine Paint'On · Label with: MB146 <F> & MB Midnight Blue"

typst compile \
    --input note="$note" \
    --input name="Midori MD A5" \
    --input cover-w=148 --input height=210 --input spine=10 --input flap=40 \
    sleeve.typ out/sleeve-midori-md-a5.pdf

typst compile \
    --input note="$note" \
    --input name="Leuchtturm1917 A5 Hardcover" \
    --input cover-w=146 --input height=208 --input spine=20 --input flap=40 \
    sleeve.typ out/sleeve-leuchtturm1917-a5.pdf

typst compile \
    --input note="$note" \
    --input name="Hobonichi Techo A5" \
    --input cover-w=146 --input height=210 --input spine=8 --input flap=40 \
    sleeve.typ out/sleeve-hobonichi-techo-a5.pdf

typst compile \
    --input note="$note" \
    --input name="Life Noble Note A5" \
    --input cover-w=148 --input height=210 --input spine=11 --input flap=40 \
    sleeve.typ out/sleeve-life-noble-note-a5.pdf
