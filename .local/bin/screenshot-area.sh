#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

# Выделение рамкой с цветом #a6e3a1
GEOM=$(slurp -b "#11111b80" -c "#a6e3a1" -w 2)

# Если нажали Escape или кликнули мимо — просто выходим
[ -z "$GEOM" ] && exit 0

FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

# Захват, сохранение в файл и копирование в буфер
grim -g "$GEOM" - | tee "$FILE" | wl-copy --type image/png

# Звук или уведомление (если есть dunst/mako)
command -v notify-send >/dev/null && notify-send -a "Screenshot" "Скриншот сохранён" "$FILE"
