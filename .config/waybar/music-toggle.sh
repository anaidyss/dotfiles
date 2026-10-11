#!/usr/bin/env bash
# Кнопка переключения режима (info/lyrics) — только при активном плеере.
f="$HOME/.cache/veil-music/bar_text.json"
[ -f "$f" ] || exit 0
if jq -e '.class == "disconnected"' "$f" >/dev/null 2>&1; then
    exit 0
fi
b="$HOME/.cache/veil-music/bar_btn.json"
[ -f "$b" ] || exit 0
cat "$b"