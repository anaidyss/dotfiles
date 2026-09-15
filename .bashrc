# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
# Делаем так, чтобы простой ввод eza сразу рисовал дерево с иконками
alias eza='eza -l --tree --icons'
alias wp='wallpaper'  # смена обоев: wp / wp list / wp next / wp random

# Секреты (API-ключи и т.п.) — в отдельном файле с правами 600, не коммитить
if [ -f ~/.config/secrets/env ]; then
    set -a
    . ~/.config/secrets/env
    set +a
fi

