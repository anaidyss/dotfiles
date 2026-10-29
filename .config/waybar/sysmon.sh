#!/usr/bin/env bash
# Retro-телеметрия для waybar: CPU / память / direct / vpn / пинг+нода.
# Показывает данные только когда режим = sysmon (иначе выводит пустую строку).
# Блок-бары ▁▂▃▄▅▆▇█ с термокартой по уровню нагрузки.

MODE_FILE="$HOME/.cache/waybar-center"
SPARK=8               # точек в одном спарклайне
POLL=0.2              # шаг опроса режима (с)
VPN_STATE=/run/vpnstat/state
PING_TARGET=http://1.1.1.1/
NODE_API=http://127.0.0.1:9090/proxies/proxy

c_lbl='#e8c987'      # иконки подписей
c_val='#d5d5d3'      # числа
C_LOW='#73736f'      # термокарта: низкая нагрузка
C_MID='#d87756'      # средняя / зелёный / reality / пинг ок
C_HIGH='#e8c987'     # высокая / янтарный / hysteria2 / пинг повышен
C_CRIT='#e5534b'     # критичная / красный / пинг плохой

ICON_CPU=$'\uf4bc'
ICON_MEM=$'\ue266'
ICON_DIR=$'\uf0ac'
ICON_VPN=$'\U000f0582'
ICON_PING=$'\U000f029a'

# 8-уровневый блок-бар, заполнение снизу вверх (0..7)
levels=($'\u2581' $'\u2582' $'\u2583' $'\u2584' $'\u2585' $'\u2586' $'\u2587' $'\u2588')

NET_FLOOR=51200        # ниже 50 KiB/s шкала считается пустой

mode() { cat "$MODE_FILE" 2>/dev/null || echo sysmon; }

read_cpu() { awk '/^cpu /{t=$2+$3+$4+$5+$6+$7+$8+$9; i=$5+$6; printf "%d %d", t, i}' /proc/stat; }
read_mem() { awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d %d", t, a}' /proc/meminfo; }

rate3() {
    local b=$1 n=0 u=B
    if   (( b >= 1000000000 )); then n=$(( b / 1000000000 )); u=G
    elif (( b >= 1000000 ));    then n=$(( b / 1000000 ));    u=M
    elif (( b >= 1000 ));       then n=$(( b / 1000 ));       u=K
    else                        n=$b;                          u=B
    fi
    printf '%3d%s' "$n" "$u"
}

push() {
    local -n _a=$1
    _a+=("$2")
    while (( ${#_a[@]} > SPARK )); do _a=("${_a[@]:1}"); done
}

bar_color() {
    local lvl=$1
    if   (( lvl >= 7 )); then printf '%s' "$C_CRIT"
    elif (( lvl >= 5 )); then printf '%s' "$C_HIGH"
    elif (( lvl >= 3 )); then printf '%s' "$C_MID"
    else                     printf '%s' "$C_LOW"
    fi
}

spark() {
    local -n _a=$1
    local scale=$2
    local n=${#_a[@]} v lvl out="" i
    local skip=2
    out+="  "
    for (( i = skip; i < n; i++ )); do
        v=${_a[i]}
        if (( scale > 0 )); then lvl=$(( (v * 7 + scale / 2) / scale )); else lvl=0; fi
        (( lvl < 0 )) && lvl=0
        (( lvl > 7 )) && lvl=7
        out+="<span foreground='$(bar_color "$lvl")'>${levels[$lvl]}</span>"
    done
    echo "$out"
}

# сокращённая подпись активной ноды
node_label() {
    case "$1" in
        aws-h2)      echo "AWS·h2" ;;
        aws-reality) echo "AWS·rt" ;;
        bwh-h2)      echo "BWH·h2" ;;
        skvoza-de)   echo "SKV·de" ;;
        skvoza-md)   echo "SKV·md" ;;
        direct)      echo "direct" ;;
        *)           echo "$1" ;;
    esac
}

node_color() {
    case "$1" in
        *h2*)      printf '%s' "$C_HIGH" ;;
        *reality*) printf '%s' "$C_MID"  ;;
        *)         printf '%s' "$C_LOW"  ;;
    esac
}

ping_color() {
    local ms=$1
    if   (( ms >= 150 )); then printf '%s' "$C_CRIT"
    elif (( ms >= 50 ));  then printf '%s' "$C_HIGH"
    else                      printf '%s' "$C_MID"
    fi
}

hist_cpu=(); hist_mem=(); hist_direct=(); hist_vpn=()
for (( i = 0; i < SPARK; i++ )); do
    hist_cpu+=(0); hist_mem+=(0); hist_direct+=(0); hist_vpn+=(0)
done

# прайм
cpu_prev=($(read_cpu))
st_prev=($(cat "$VPN_STATE" 2>/dev/null || printf '0 0 0 0'))
[ ${#st_prev[@]} -lt 4 ] && st_prev=(0 0 0 0)
shown=1
tick=0
ping_ms=""
node=""

while true; do
    cur=$(mode)
    if [ "$cur" != "sysmon" ]; then
        echo ""
        shown=0
        sleep "$POLL"
        continue
    fi
    if (( shown == 0 )); then
        cpu_prev=($(read_cpu))
        st_prev=($(cat "$VPN_STATE" 2>/dev/null || printf '0 0 0 0'))
        [ ${#st_prev[@]} -lt 4 ] && st_prev=(0 0 0 0)
        shown=1
        sleep "$POLL"
        continue
    fi

    tick=$((tick + 1))

    # --- пинг (TCP-handshake через VPN, каждые 5 тиков) ---
    if (( tick % 5 == 0 )); then
        t=$(curl -s -o /dev/null -w '%{time_connect}' --max-time 3 "$PING_TARGET" 2>/dev/null)
        if [ -n "$t" ]; then ping_ms=$(awk -v t="$t" 'BEGIN{printf "%d", t*1000}'); fi
    fi

    # --- активная нода (каждые 3 тика) ---
    if (( tick % 3 == 0 )); then
        n=$(curl -sf --max-time 2 "$NODE_API" 2>/dev/null | jq -r '.now // empty' 2>/dev/null)
        [ -n "$n" ] && node="$n"
    fi

    # --- CPU ---
    cpu_now=($(read_cpu))
    dt=$(( cpu_now[0] - cpu_prev[0] )); di=$(( cpu_now[1] - cpu_prev[1] ))
    cpu_pct=0
    (( dt > 0 )) && cpu_pct=$(( (dt - di) * 100 / dt ))
    cpu_prev=("${cpu_now[@]}")

    # --- память ---
    mem=($(read_mem))
    mem_pct=0
    (( mem[0] > 0 )) && mem_pct=$(( (mem[0] - mem[1]) * 100 / mem[0] ))

    # --- direct / vpn ---
    st=($(cat "$VPN_STATE" 2>/dev/null))
    if [ ${#st[@]} -eq 4 ]; then
        wrx=$(( st[0] - st_prev[0] )); wtx=$(( st[1] - st_prev[1] ))
        vrx=$(( st[2] - st_prev[2] )); vtx=$(( st[3] - st_prev[3] ))
        (( wrx < 0 )) && wrx=0; (( wtx < 0 )) && wtx=0
        (( vrx < 0 )) && vrx=0; (( vtx < 0 )) && vtx=0
        wlp=$(( wrx + wtx )); vpn=$(( vrx + vtx ))
        direct=$(( wlp - vpn )); (( direct < 0 )) && direct=0
        st_prev=("${st[@]}")
    else
        direct=0; vpn=0
    fi

    push hist_cpu "$cpu_pct"
    push hist_mem "$mem_pct"
    push hist_direct "$direct"
    push hist_vpn "$vpn"

    scale_direct=$NET_FLOOR; scale_vpn=$NET_FLOOR
    for v in "${hist_direct[@]}"; do (( v > scale_direct )) && scale_direct=$v; done
    for v in "${hist_vpn[@]}";    do (( v > scale_vpn ))    && scale_vpn=$v;   done

    # --- подписи/цвета статуса ---
    if [ -n "$node" ]; then
        lbl=$(node_label "$node"); ncol=$(node_color "$node")
    else
        lbl="…"; ncol=$C_LOW
    fi
    if [ -n "$ping_ms" ]; then
        pidx=$(printf '%3d' "$ping_ms"); pcol=$(ping_color "$ping_ms")
    else
        pidx="---"; pcol=$C_LOW
    fi
    cpu_v=$(printf '%3d%%' "$cpu_pct")
    mem_v=$(printf '%3d%%' "$mem_pct")

    text=""
    text+="<span foreground='$c_lbl'>$ICON_CPU</span>$(spark hist_cpu 100)<span foreground='$c_val'> $cpu_v </span>"
    text+="  "
    text+="<span foreground='$c_lbl'>$ICON_MEM</span>$(spark hist_mem 100)<span foreground='$c_val'> $mem_v </span>"
    text+="  "
    text+="<span foreground='$c_lbl'>$ICON_DIR</span>$(spark hist_direct $scale_direct)<span foreground='$c_val'> $(rate3 "$direct") </span>"
    text+="  "
    text+="<span foreground='$c_lbl'>$ICON_VPN</span>$(spark hist_vpn $scale_vpn)<span foreground='$c_val'> $(rate3 "$vpn") </span>"
    text+="  "
    text+="<span foreground='$c_lbl'>$ICON_PING</span><span foreground='$pcol'> ${pidx}ms </span><span foreground='$ncol'>${lbl}</span>"

    tooltip="CPU ${cpu_pct}% · MEM ${mem_pct}% · direct $(rate3 "$direct")/s · vpn $(rate3 "$vpn")/s · ping ${ping_ms:-?}ms · ${node:-?}"

    printf '{"text": "%s", "tooltip": "%s", "class": "sysmon"}\n' "$text" "$tooltip"

    for _ in 1 2 3 4 5; do
        if [ "$(mode)" != "sysmon" ]; then break; fi
        sleep "$POLL"
    done
done