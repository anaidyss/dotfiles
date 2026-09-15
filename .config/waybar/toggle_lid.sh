#!/usr/bin/env bash
if systemctl --user is-active --quiet lid-sleep.service; then
    systemctl --user disable --now lid-sleep.service
else
    systemctl --user enable --now lid-sleep.service
fi
