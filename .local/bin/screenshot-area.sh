#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# selection outline in #a6e3a1
GEOM=$(slurp -b "#11111b80" -c "#a6e3a1" -w 2)

# escape or a stray click: just exit
[ -z "$GEOM" ] && exit 0

FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

# capture, save to file and copy to clipboard
grim -g "$GEOM" - | tee "$FILE" | wl-copy --type image/png

# sound or notification (if dunst/mako is present)
command -v notify-send >/dev/null && notify-send -a "Screenshot" "screenshot saved" "$FILE"
