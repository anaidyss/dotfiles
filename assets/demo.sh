#!/usr/bin/env bash
# the session that ends up in assets/demo.gif: real fastfetch, eza and bat
# against the repo itself, nothing is staged
export LANG=C.utf8
cd "$HOME/dotfiles"

type_cmd() {
    printf '\033[1;32m$\033[0m '
    local s="$1" i
    for (( i=0; i<${#s}; i++ )); do
        printf '%s' "${s:i:1}"
        sleep 0.055
    done
    printf '\n'
    sleep 0.35
}

run() {
    type_cmd "$1"
    eval "$1"
    sleep 1.2
}

sleep 0.7
run 'fastfetch'
run 'eza -1 --icons .config'
run 'bat --paging=never -pp -r 10:35 .config/kitty/current-theme.conf'
sleep 1.5
