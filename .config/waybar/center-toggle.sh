#!/usr/bin/env bash
# Переключает центральный виджет waybar: понг <-> телеметрия.
f="$HOME/.cache/waybar-center"
mkdir -p "$(dirname "$f")"
cur=$(cat "$f" 2>/dev/null || echo sysmon)
next=sysmon
[ "$cur" = "sysmon" ] && next=pong
tmp="$f.tmp"
printf '%s' "$next" > "$tmp"
mv "$tmp" "$f"