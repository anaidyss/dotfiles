#!/bin/sh

# Принудительно переключаем раскладку на английский (первая в списке us, индекс 0)
niri msg action switch-layout 0

# Удаляем старый скриншот и делаем новый
rm -f /tmp/screen_lock.png
grim /tmp/screen_lock.png

# Запускаем локскрин
hyprlock
