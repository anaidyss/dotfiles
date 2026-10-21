#!/usr/bin/env bash
if systemctl --user is-active --quiet lid-sleep.service; then
    echo '{"text": "󰒲", "tooltip": "Sleep on lid close: on", "alt": "lid-sleep", "class": "lid-sleep"}'
else
    echo '{"text": "󰅖", "tooltip": "Sleep on lid close: off", "alt": "lid-nosleep", "class": "lid-nosleep"}'
fi
