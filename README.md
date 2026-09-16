# dotfiles

fedora 44 + niri. everything in one palette ("forest"):
background #131a16, green #a6e3a1, teal #59c2a5, amber #e3c078, errors #c9745c.

- wm: niri
- bar: waybar + swayosd
- terminal: kitty, fish, starship
- launcher: fuzzel
- lock: hyprlock (forest) and veil (separate repo)
- editor: nvim, lazy.nvim + gruvbox with an overridden palette
- the rest: fastfetch, btop, yazi, bat, eza, zoxide, mako

## install

    ./install.sh

just copies files into ~. secrets, vpn and browser configs are not included.

font everywhere is JetBrainsMono Nerd Font (lives in ~/.local/share/fonts).

## veil

the veil lockscreen (ext-session-lock-v1, python) lives in its own repo:
https://github.com/anaidyss/veil, installed with its own install.sh,
niri bind: Mod+Shift+V.

## lid-sleep

the .config/systemd/user/lid-sleep.service unit + waybar/lid-watcher.sh:
suspends the laptop when the lid closes, toggled by clicking the module in the bar.
