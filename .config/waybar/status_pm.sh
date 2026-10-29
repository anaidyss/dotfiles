#!/usr/bin/env bash
CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "performance" ]; then
    echo '{"text": "󰓅", "tooltip": "Режим: производительность", "alt": "performance", "class": "performance"}'
elif [ "$CURRENT" = "power-saver" ]; then
    echo '{"text": "󰌪", "tooltip": "Режим: энергосбережение", "alt": "power-saver", "class": "power-saver"}'
else
    echo '{"text": "󰾆", "tooltip": "Режим: сбалансированный", "alt": "balanced", "class": "balanced"}'
fi
