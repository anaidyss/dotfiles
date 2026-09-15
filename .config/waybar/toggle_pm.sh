#!/usr/bin/env bash
CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "performance" ]; then
    powerprofilesctl set power-saver
else
    powerprofilesctl set performance
fi
