#!/usr/bin/env bash
# watches the lid state and suspends the laptop on open -> closed.
# only works while the lid-sleep.service user service is running.

state_file=""
for f in /proc/acpi/button/lid/*/state; do
    if [ -r "$f" ]; then
        state_file="$f"
        break
    fi
done

if [ -z "$state_file" ]; then
    echo "lid state file not found" >&2
    exit 1
fi

read_state() {
    awk '{print $2}' "$state_file"
}

prev=$(read_state)

while sleep 1; do
    cur=$(read_state)
    if [ "$prev" = "open" ] && [ "$cur" = "closed" ]; then
        echo "lid closed, suspending"
        systemctl suspend
    fi
    prev="$cur"
done
