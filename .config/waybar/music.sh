#!/usr/bin/env bash
# Показывать виджет музыки только при активном MPRIS-плеере.
# При отсутствии плеера вывода нет — waybar скрывает модуль полностью.
f="$HOME/.cache/veil-music/bar_text.json"
[ -f "$f" ] || exit 0
if jq -e '.class == "disconnected"' "$f" >/dev/null 2>&1; then
    exit 0
fi
cat "$f"