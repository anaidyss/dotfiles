#!/bin/sh

# Проверяем, запущен ли процесс happ или есть ли активный tun-интерфейс
if ip link show 2>/dev/null | grep -q "tun" || pgrep -x "happ" >/dev/null; then
    echo '{"text": "VPN: ON", "class": "connected", "tooltip": "Happ VPN активен"}'
else
    echo '{"text": "VPN: OFF", "class": "disconnected", "tooltip": "Happ VPN отключен"}'
fi
