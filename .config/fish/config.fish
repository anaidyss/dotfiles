if status is-interactive
    # Секреты (API-ключи и т.п.) — файл с правами 600, не коммитить
    if test -f ~/.config/secrets/env
        for line in (string match -rv '^\s*(#|$)' < ~/.config/secrets/env)
            set -l kv (string split -m1 = $line)
            if test (count $kv) -eq 2
                set -gx (string trim $kv[1]) (string trim $kv[2])
            end
        end
    end

    # Промпт и умная навигация
    starship init fish | source
    zoxide init fish | source

    # Алиасы
    alias ls="eza --icons"
    alias cd="z"
    alias du="dust"
    alias ps="procs"
    alias ff="fastfetch"
    alias cat="bat --plain"   # без пагинации, чтобы вывод не застревал
    alias b="bat"             # быстрый просмотр с подсветкой
    alias tty="tty-clock -c -C 6"
    alias pipes="pipes.sh -t 0 -p 3 -R -c 2 -c 6 -c 10 -f 60"
    alias wp="wallpaper"        # смена обоев: wp / wp list / wp next / wp random
    # Лава-лампа: truecolor-градиент зелёный → бирюзовый
    alias lava="lavat -g -c a6e3a1 -k 59c2a5"
end

function eza
    tput rmam  # Отключаем перенос строк (строки будут обрезаться краем окна)
    command eza -l --tree --icons $argv
    tput smam  # Включаем перенос строк обратно для нормальной работы терминала
end

function ll
    tput rmam
    command eza -la --icons $argv
    tput smam
end
