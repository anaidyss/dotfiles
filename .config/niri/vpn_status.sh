#!/bin/sh

# check if the happ process is running or there's an active tun interface
if ip link show 2>/dev/null | grep -q "tun" || pgrep -x "happ" >/dev/null; then
    echo '{"text": "VPN: ON", "class": "connected", "tooltip": "Happ VPN active"}'
else
    echo '{"text": "VPN: OFF", "class": "disconnected", "tooltip": "Happ VPN off"}'
fi
