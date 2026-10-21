#!/usr/bin/env bash
CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "performance" ]; then
    echo '{"text": "󰓅", "tooltip": "Mode: performance", "alt": "performance", "class": "performance"}'
elif [ "$CURRENT" = "power-saver" ]; then
    echo '{"text": "󰌪", "tooltip": "Mode: power saver", "alt": "power-saver", "class": "power-saver"}'
else
    echo '{"text": "󰾆", "tooltip": "Mode: balanced", "alt": "balanced", "class": "balanced"}'
fi
