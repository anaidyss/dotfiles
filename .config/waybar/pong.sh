#!/usr/bin/env bash
# ASCII ping-pong для waybar: две ракетки гоняются за шариком.
# Занимает центр бара (модуль custom/pong с expand: true).
# Ширина поля задаётся первым аргументом, по умолчанию 96.

W=${1:-96}
(( W < 12 )) && W=12

MODE_FILE="$HOME/.cache/waybar-center"

LEFT='▐'    # левая ракетка (лицом к полю)
RIGHT='▌'   # правая ракетка
BALL='●'
FILL='·'

c_fill='#6a6a66'
c_paddle='#e8c987'
c_ball='#d5d5d3'

x=$((W / 2))     # позиция шарика
dx=1             # скорость (+/-1..2)
pl=2             # позиция левой ракетки
pr=$((W - 3))    # позиция правой ракетки
half=$((W / 2))

while true; do
    # рисуем только в режиме pong; иначе пусто (waybar скрывает модуль)
    if [ "$(cat "$MODE_FILE" 2>/dev/null || echo sysmon)" != "pong" ]; then
        echo ""
        sleep 0.2
        continue
    fi

    # --- ракетки тянутся к шарику (каждая на своей половине) ---
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

    # --- движение шарика и отскоки ---
    x=$((x + dx))
    if (( x <= pl )); then
        x=$((pl + 1))
        dx=$((1 + RANDOM % 2))
    elif (( x >= pr )); then
        x=$((pr - 1))
        dx=$((-1 - RANDOM % 2))
    fi

    # --- рендер кадра ---
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