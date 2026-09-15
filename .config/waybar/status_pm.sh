#!/usr/bin/env bash
CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "performance" ]; then
    echo '{"text": "󰓅 perf", "alt": "performance", "class": "performance"}'
elif [ "$CURRENT" = "power-saver" ]; then
    echo '{"text": "󰌪 save", "alt": "power-saver", "class": "power-saver"}'
else
    echo '{"text": "󰾆 balanced", "alt": "balanced", "class": "balanced"}'
fi
