#!/usr/bin/env bash
# copies configs into place. no symlinks, keeping it simple
set -euo pipefail
cd "$(dirname "$0")"

cp -f .bashrc .nanorc ~/

mkdir -p ~/.config ~/.local/bin
cp -rf .config/. ~/.config/
cp -f .local/bin/* ~/.local/bin/

chmod +x ~/.local/bin/* ~/.config/niri/*.sh ~/.config/waybar/*.sh

systemctl --user daemon-reload

echo "done. veil is installed separately from its own repo"
