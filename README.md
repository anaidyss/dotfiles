# dotfiles

fedora 44 + niri. всё в одной палитре ("forest"):
фон #131a16, зелёный #a6e3a1, бирюза #59c2a5, янтарь #e3c078, ошибки #c9745c.

- wm: niri
- бар: waybar + swayosd
- терминал: kitty, fish, starship
- лаунчер: fuzzel
- блокировка: hyprlock (forest) и veil (отдельное репо)
- редактор: nvim, lazy.nvim + gruvbox с переопределённой палитрой
- остальное: fastfetch, btop, yazi, bat, eza, zoxide, mako

## установка

    ./install.sh

просто копирует файлы в ~. секреты, vpn и конфиги браузеров сюда не входят.

шрифт везде JetBrainsMono Nerd Font (лежит в ~/.local/share/fonts).

## veil

локскрин veil (ext-session-lock-v1, python) лежит отдельно:
https://github.com/anaidyss/veil — ставится своим install.sh,
бинд в niri: Mod+Shift+V.

## lid-sleep

юнит .config/systemd/user/lid-sleep.service + waybar/lid-watcher.sh:
усыпляет ноут при закрытии крышки, переключается кликом по модулю в баре.
