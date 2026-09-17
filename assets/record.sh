#!/usr/bin/env bash
# rebuilds assets/demo.gif: asciinema records demo.sh, termtosvg renders the
# svg animation with the forest template, headless chrome rasterizes it at
# fixed virtual times, ffmpeg assembles a palette gif.
#
# needs: python3, ffmpeg, google-chrome (any chromium), imagemagick for the
# blank frame check, network for pip.
set -euo pipefail
cd "$(dirname "$0")"

STEP=${STEP:-150}          # ms per frame
SCALE=${SCALE:-2}          # chrome device scale; 1 renders blank, do not touch
WIDTH=${WIDTH:-640}        # final gif width
FPS=${FPS:-6}
COLORS=${COLORS:-64}
DITHER=${DITHER:-none}     # flat terminal text: none compresses far better
W=800
H=478

TOOLS=${TOOLS:-/tmp/gif-tools}
if [ ! -x "$TOOLS/venv/bin/asciinema" ]; then
    python3 -m venv "$TOOLS/venv"
    "$TOOLS/venv/bin/pip" install -q asciinema termtosvg
fi
ASCI="$TOOLS/venv/bin/asciinema"
TSVG="$TOOLS/venv/bin/termtosvg"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo "recording"
"$ASCI" rec --overwrite -i 0.7 --cols 100 --rows 28 \
    -c "bash $PWD/demo.sh" "$work/demo.cast" >/dev/null

echo "rendering svg"
"$TSVG" render "$work/demo.cast" "$work/demo.svg" -t "$PWD/forest.svg" >/dev/null

# the nerd font has to come first, otherwise the fastfetch icons and the
# eza file icons fall back to empty boxes
sed -i "s/font-family: [^;]*;/font-family: 'JetBrainsMono Nerd Font', 'Noto Sans Mono CJK SC', monospace;/" \
    "$work/demo.svg"
dur=$(grep -o 'animation-duration: [0-9]*ms' "$work/demo.svg" | head -1 | grep -o '[0-9]*')
echo "animation is ${dur}ms"

echo "rasterizing frames"
mkdir -p "$work/frames"
i=0
t=$STEP
while [ "$t" -le "$dur" ]; do
    (
        timeout 90 google-chrome --headless=new --disable-gpu --no-sandbox \
            --hide-scrollbars --user-data-dir="$work/chrome-$i" \
            --window-size="${W},${H}" --force-device-scale-factor="${SCALE}" \
            --default-background-color=FF000000 \
            --virtual-time-budget="$t" --screenshot="$work/raw-$i.png" \
            "file://$work/demo.svg" >/dev/null 2>&1 || true
        rm -rf "$work/chrome-$i"
    ) &
    i=$((i + 1))
    t=$((t + STEP))
    [ $((i % 6)) -eq 0 ] && wait
done
wait

# chrome paints a white page before the svg is drawn, so the first frames of a
# recording are blank. drop anything with almost no colors in it.
n=0
for f in "$work"/raw-*.png; do
    [ -f "$f" ] || continue
    c=$(magick identify -format "%k" "$f" 2>/dev/null || echo 0)
    if [ "${c:-0}" -ge 30 ]; then
        printf -v out "$work/frames/f%04d.png" "$n"
        mv "$f" "$out"
        n=$((n + 1))
    else
        rm -f "$f"
    fi
done
echo "usable frames: $n"
[ "$n" -gt 10 ] || { echo "too few frames, something went wrong"; exit 1; }

echo "encoding gif"
ffmpeg -y -loglevel error -framerate "$FPS" -i "$work/frames/f%04d.png" \
    -vf "scale=${WIDTH}:-1:flags=lanczos,palettegen=max_colors=${COLORS}:stats_mode=diff" \
    "$work/palette.png"
ffmpeg -y -loglevel error -framerate "$FPS" -i "$work/frames/f%04d.png" \
    -i "$work/palette.png" \
    -lavfi "scale=${WIDTH}:-1:flags=lanczos [x]; [x][1:v] paletteuse=dither=${DITHER}" \
    demo.gif

ls -la demo.gif
ffprobe -v error -select_streams v:0 \
    -show_entries stream=nb_frames,width,height -of csv=p=0 demo.gif
