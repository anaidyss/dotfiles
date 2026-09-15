#!/usr/bin/env bash
# копирует конфиги на места. без симлинков, все по-простому
set -euo pipefail
cd "$(dirname "$0")"

cp -f .bashrc .nanorc ~/

mkdir -p ~/.config ~/.local/bin ~/.local/share/veil/xml
cp -rf .config/. ~/.config/
cp -f .local/bin/* ~/.local/bin/
cp -f .local/share/veil/veil_lock.py ~/.local/share/veil/
cp -f .local/share/veil/xml/*.xml ~/.local/share/veil/xml/

chmod +x ~/.local/bin/* ~/.config/niri/*.sh ~/.config/waybar/*.sh

systemctl --user daemon-reload

echo "готово. для veil еще нужен venv и биндинги протоколов — см. README"
