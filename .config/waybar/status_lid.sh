#!/usr/bin/env bash
if systemctl --user is-active --quiet lid-sleep.service; then
    echo '{"text": "󰒲 sleep", "alt": "lid-sleep", "class": "lid-sleep"}'
else
    echo '{"text": "󰅖 nosleep", "alt": "lid-nosleep", "class": "lid-nosleep"}'
fi
