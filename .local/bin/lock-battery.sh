#!/bin/sh
# battery icon + percent for hyprlock, color depends on the charge

PS=/sys/class/power_supply/BAT0
[ -r "$PS/capacity" ] || exit 0
cap=$(cat "$PS/capacity")
st=$(cat "$PS/status" 2>/dev/null)

case "$st" in
    Charging) icon="󰂄"; color="#59c2a5"; note="charging" ;;
    Full)     icon="󰁹"; color="#a6e3a1"; note="" ;;
    *)
        if   [ "$cap" -ge 95 ]; then icon="󰁹"
        elif [ "$cap" -ge 85 ]; then icon="󰂂"
        elif [ "$cap" -ge 75 ]; then icon="󰂁"
        elif [ "$cap" -ge 65 ]; then icon="󰂀"
        elif [ "$cap" -ge 55 ]; then icon="󰁿"
        elif [ "$cap" -ge 45 ]; then icon="󰁾"
        elif [ "$cap" -ge 35 ]; then icon="󰁽"
        elif [ "$cap" -ge 25 ]; then icon="󰁼"
        elif [ "$cap" -ge 15 ]; then icon="󰁻"
        else icon="󰁺"
        fi
        if   [ "$cap" -le 15 ]; then color="#c9745c"; note="low"
        elif [ "$cap" -le 30 ]; then color="#e3c078"; note=""
        else color="#a6e3a1"; note=""
        fi
        ;;
esac

printf '<span foreground="%s"><b>%s %s%%</b></span>' "$color" "$icon" "$cap"
[ -n "$note" ] && printf ' <span foreground="#93a598">%s</span>' "$note"
