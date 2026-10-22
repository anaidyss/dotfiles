#!/usr/bin/env bash
# installs VSCodium from the official tarball into ~/.local/opt/vscodium (no root),
# verifies the sha256, writes a wayland wrapper + desktop entry and installs the veil theme.
# usage: ./install-codium.sh [--force]     DRY_RUN=1 ./install-codium.sh   (only resolve the release)
set -euo pipefail

DEST="$HOME/.local/opt/vscodium"
API="https://api.github.com/repos/VSCodium/vscodium/releases/latest"

if [ -d "$DEST" ] && [ "${1:-}" != "--force" ] && [ "${DRY_RUN:-}" != 1 ]; then
  echo "already installed in $DEST (use --force to reinstall)"; exit 0
fi

# resolve the latest linux-x64 tarball and its checksum file
read -r tag url sumurl < <(curl -fsSL "$API" | python3 -I -c '
import json, sys
d = json.load(sys.stdin); tag = d["tag_name"]; a = {x["name"]: x["browser_download_url"] for x in d["assets"]}
n = f"VSCodium-linux-x64-{tag}.tar.gz"
print(tag, a[n], a[n + ".sha256"])')
echo "vscodium $tag"
[ "${DRY_RUN:-}" = 1 ] && { echo "$url"; echo "$sumurl"; exit 0; }

# download into a fresh dir (untrusted data), verify before touching anything
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
curl -fL --retry 3 -o "$tmp/vscodium.tar.gz" "$url"
curl -fsSL -o "$tmp/vscodium.tar.gz.sha256" "$sumurl"
want=$(awk '{print $1}' "$tmp/vscodium.tar.gz.sha256"); got=$(sha256sum "$tmp/vscodium.tar.gz" | awk '{print $1}')
[ "$want" = "$got" ] || { echo "sha256 mismatch, aborting" >&2; exit 1; }
tar tzf "$tmp/vscodium.tar.gz" | grep -qE '^/|(^|/)\.\.(/|$)' && { echo "unsafe paths in archive, aborting" >&2; exit 1; }

rm -rf "$DEST"; mkdir -p "$DEST" ~/.local/bin ~/.local/share/applications
tar xzf "$tmp/vscodium.tar.gz" -C "$DEST" --no-same-owner

# wayland wrapper (also shipped in .local/bin/codium) and desktop entry
[ -x ~/.local/bin/codium ] || {
  printf '#!/usr/bin/env bash\nexec "$HOME/.local/opt/vscodium/bin/codium" --ozone-platform=wayland "$@"\n' > ~/.local/bin/codium
  chmod +x ~/.local/bin/codium; }
cat > ~/.local/share/applications/codium.desktop <<DESK
[Desktop Entry]
Name=VSCodium
GenericName=Text Editor
Comment=Code editing. Redefined.
Exec=$HOME/.local/bin/codium %F
Icon=$DEST/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=VSCodium
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
DESK

# veil color themes generated from ~/.config/theme/palette.toml
python3 -I ~/.config/theme/tools/vscode-theme.py
echo "done: run 'codium'"
