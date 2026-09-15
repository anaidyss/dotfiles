#!/bin/sh
# Музыка (MPRIS) для Forest Lock — тихий текст, без иконок
# Ничего не играет — ничего не показываем

title=$(playerctl metadata --format '{{title}}' 2>/dev/null)
artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null)
status=$(playerctl status 2>/dev/null)

[ -z "$title" ] && exit 0

esc() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

title=$(printf '%s' "$title" | cut -c1-36)
artist=$(printf '%s' "$artist" | cut -c1-24)

if [ "$status" = "Paused" ]; then
    printf '<span foreground="#64766a">%s</span>' "$(esc "$title")"
    [ -n "$artist" ] && printf '<span foreground="#4f6157"> · %s</span>' "$(esc "$artist")"
else
    printf '<span foreground="#cddbd0">%s</span>' "$(esc "$title")"
    [ -n "$artist" ] && printf '<span foreground="#93a598"> · %s</span>' "$(esc "$artist")"
fi
