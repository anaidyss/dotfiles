#!/bin/sh

# force the layout to english (us is first in the list, index 0)
niri msg action switch-layout 0

# remove the old screenshot and take a new one
rm -f /tmp/screen_lock.png
grim /tmp/screen_lock.png

# start the lockscreen
hyprlock
