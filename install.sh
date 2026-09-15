#!/usr/bin/env bash
# копирует конфиги на места. без симлинков, все по-простому
set -euo pipefail
cd "$(dirname "$0")"

cp -f .bashrc .nanorc ~/

mkdir -p ~/.config ~/.local/bin
cp -rf .config/. ~/.config/
cp -f .local/bin/* ~/.local/bin/

chmod +x ~/.local/bin/* ~/.config/niri/*.sh ~/.config/waybar/*.sh

systemctl --user daemon-reload

echo "готово. veil ставится отдельно из своего репо"
