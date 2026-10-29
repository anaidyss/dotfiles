#!/usr/bin/env bash
# Жёсткая блокировка встроенных динамиков (ALSA Speaker + Bass Speaker).
# Наушники (3.5 мм, Bluetooth, HDMI) не затрагиваются.
CARD=sofhdadsp
UNIT=speaker-guard.service
CTLS=("Speaker" "Bass Speaker")

is_on() { amixer -c "$CARD" sget "$1" 2>/dev/null | grep -q '\[on\]'; }

enforce() {
    for c in "${CTLS[@]}"; do
        is_on "$c" && amixer -c "$CARD" -q sset "$c" mute
    done
}

release() {
    for c in "${CTLS[@]}"; do
        amixer -c "$CARD" -q sset "$c" unmute
    done
}

case "$1" in
watch)
    # WirePlumber при любом переключении mute заново включает Speaker — перемучиваем.
    enforce
    stdbuf -oL alsactl monitor "hw:$CARD" | while read -r line; do
        case $line in *Speaker*) enforce ;; esac
    done
    ;;
toggle)
    if systemctl --user is-active --quiet "$UNIT"; then
        systemctl --user disable --now "$UNIT"
        release
    else
        systemctl --user enable --now "$UNIT"
    fi
    pkill -RTMIN+8 waybar
    ;;
status)
    if systemctl --user is-active --quiet "$UNIT"; then
        echo '{"text": "󰋋", "tooltip": "Динамики ноутбука: заблокированы (только наушники)", "alt": "guard-on", "class": "guard-on"}'
    else
        echo '{"text": "󰓃", "tooltip": "Динамики ноутбука: разрешены", "alt": "guard-off", "class": "guard-off"}'
    fi
    ;;
*)
    echo "usage: $0 {watch|toggle|status}" >&2
    exit 1
    ;;
esac
