#!/usr/bin/env bash
# Cycles the central waybar widget.
modes=(sysmon chase match snake satellite spring)

f="$HOME/.cache/waybar-center"
mkdir -p "$(dirname "$f")"
cur=$(cat "$f" 2>/dev/null || echo sysmon)

next="${modes[0]}"
for i in "${!modes[@]}"; do
    if [[ "${modes[$i]}" == "$cur" ]]; then
        next="${modes[$(( (i + 1) % ${#modes[@]} ))]}"
        break
    fi
done

tmp="$f.tmp"
printf '%s' "$next" > "$tmp"
mv "$tmp" "$f"