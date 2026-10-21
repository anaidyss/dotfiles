#!/usr/bin/env bash
# ASCII ping-pong for waybar: two paddles chase the ball.
# Occupies the center of the bar (custom/pong module with expand: true).
# Field width is the first argument, default 96.

W=${1:-96}
(( W < 12 )) && W=12

MODE_FILE="$HOME/.cache/waybar-center"

LEFT='▐'    # left paddle (facing the field)
RIGHT='▌'   # right paddle
BALL='●'
FILL='·'

c_fill='#6a6a66'
c_paddle='#e8c987'
c_ball='#d5d5d3'

x=$((W / 2))     # ball position
dx=1             # speed (+/-1..2)
pl=2             # left paddle position
pr=$((W - 3))    # right paddle position
half=$((W / 2))

while true; do
    # draw only in pong mode; otherwise empty (waybar hides the module)
    if [ "$(cat "$MODE_FILE" 2>/dev/null || echo sysmon)" != "pong" ]; then
        echo ""
        sleep 0.2
        continue
    fi

    # --- paddles follow the ball (each on its own half) ---
    if (( x < half )); then
        target=$((x - 1))
        (( target < 1 )) && target=1
    else
        target=1
    fi
    (( pl < target )) && pl=$((pl + 1))
    (( pl > target )) && pl=$((pl - 1))

    if (( x >= half )); then
        target=$((x + 1))
        (( target > W - 2 )) && target=$((W - 2))
    else
        target=$((W - 2))
    fi
    (( pr < target )) && pr=$((pr + 1))
    (( pr > target )) && pr=$((pr - 1))

    # --- ball movement and bounces ---
    x=$((x + dx))
    if (( x <= pl )); then
        x=$((pl + 1))
        dx=$((1 + RANDOM % 2))
    elif (( x >= pr )); then
        x=$((pr - 1))
        dx=$((-1 - RANDOM % 2))
    fi

    # --- frame render ---
    line=""
    for (( i = 0; i < W; i++ )); do
        if (( i == pl )); then
            line+="<span foreground='${c_paddle}'>${LEFT}</span>"
        elif (( i == pr )); then
            line+="<span foreground='${c_paddle}'>${RIGHT}</span>"
        elif (( i == x )); then
            line+="<span foreground='${c_ball}' weight='bold'>${BALL}</span>"
        else
            line+="<span foreground='${c_fill}'>${FILL}</span>"
        fi
    done

    printf '{"text": "%s", "tooltip": "", "class": "pong"}\n' "$line"
    sleep 0.07
done