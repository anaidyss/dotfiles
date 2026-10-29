#!/usr/bin/env bash
if systemctl --user is-active --quiet lid-sleep.service; then
    echo '{"text": "󰒲", "tooltip": "Сон при закрытии крышки: включён", "alt": "lid-sleep", "class": "lid-sleep"}'
else
    echo '{"text": "󰅖", "tooltip": "Сон при закрытии крышки: выключен", "alt": "lid-nosleep", "class": "lid-nosleep"}'
fi
