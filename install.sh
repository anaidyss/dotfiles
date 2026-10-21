#!/usr/bin/env bash
# copies configs into place. no symlinks, keeping it simple
set -euo pipefail
cd "$(dirname "$0")"

cp -f .bashrc .nanorc ~/

mkdir -p ~/.config ~/.local/bin ~/.local/lib ~/.local/share ~/.peaclock
cp -rf .config/. ~/.config/
cp -f .local/bin/* ~/.local/bin/
cp -rf .local/lib/. ~/.local/lib/
cp -rf .local/share/. ~/.local/share/
cp -f .peaclock/config ~/.peaclock/config

chmod +x ~/.local/bin/* ~/.config/niri/*.sh ~/.config/waybar/*.sh

systemctl --user daemon-reload

echo "done. veil is installed separately from its own repo"
echo "themes: run 'theme graphite' or 'theme forest' (needs python 3.11+)"
