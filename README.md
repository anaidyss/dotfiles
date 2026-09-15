# dotfiles

fedora 44 + niri. всё в одной палитре ("forest"):
фон #131a16, зелёный #a6e3a1, бирюза #59c2a5, янтарь #e3c078, ошибки #c9745c.

- wm: niri
- бар: waybar + swayosd
- терминал: kitty, fish, starship
- лаунчер: fuzzel
- блокировка: hyprlock (forest) и veil — свой локскрин на ext-session-lock-v1 (python)
- редактор: nvim, lazy.nvim + gruvbox с переопределённой палитрой
- остальное: fastfetch, btop, yazi, bat, eza, zoxide, mako

## установка

    ./install.sh

просто копирует файлы в ~. секреты, vpn и конфиги браузеров сюда не входят.

шрифт везде JetBrainsMono Nerd Font (лежит в ~/.local/share/fonts).

## veil

сам локскрин — .local/share/veil/veil_lock.py, запускается через ~/.local/bin/veil-lock.
нужен отдельный venv:

    python3 -m venv ~/.local/share/veil/venv
    ~/.local/share/veil/venv/bin/pip install pywayland psutil python-pam pillow

биндинги протоколов генерируются из xml/ (wayland.xml + ext-session-lock-v1.xml):

    cd ~/.local/share/veil
    venv/bin/python -m pywayland.scanner -i xml/wayland.xml xml/ext-session-lock-v1.xml -o protocols

если локер умрёт в заблокированном состоянии, niri сессию не отпустит —
выход через TTY: Ctrl+Alt+F3 и `XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 hyprlock`.

старая tui-версия для терминала: ~/.local/bin/veil_ui.py (нужен python3-textual).

## lid-sleep

юнит .config/systemd/user/lid-sleep.service + waybar/lid-watcher.sh:
усыпляет ноут при закрытии крышки, переключается кликом по модулю в баре.
