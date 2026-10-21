function fish_greeting --description "Veil-style greeting (Graphite)"
    set -l host (hostname)
    set -l frame 5c5c58
    set -l shade 5c5c58
    set -l lbl d9b36a
    set -l txt d5d5d3
    set -l dim 73736f
    set -l clay d87756

    # banner: clay fill, grey outline and shadow (like the VEIL logo on the lock screen)
    set -l art \
        ' █████╗ ███╗   ██╗ █████╗ ██╗██████╗ ██╗   ██╗███████╗███████╗' \
        '██╔══██╗████╗  ██║██╔══██╗██║██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝' \
        '███████║██╔██╗ ██║███████║██║██║  ██║ ╚████╔╝ ███████╗███████╗' \
        '██╔══██║██║╚██╗██║██╔══██║██║██║  ██║  ╚██╔╝  ╚════██║╚════██║' \
        '██║  ██║██║ ╚████║██║  ██║██║██████╔╝   ██║   ███████║███████║' \
        '╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝╚═════╝    ╚═╝   ╚══════╝╚══════╝'
    for line in $art
        echo (set_color $shade)(string replace -ra '(█+)' (set_color $clay)'$1'(set_color $shade) -- $line)(set_color normal)
    end

    set -l pretty (grep '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2- | tr -d '"')
    set -l os (string replace ' Linux' '' -- (string replace -r ' \(.*\)' '' $pretty))
    set -l kern (uname -r | string replace -r -- '-.*' '')
    set -l up (uptime -p | string replace -r '^up ' '' \
        | string replace -ra ' days?' 'd' \
        | string replace -ra ' hours?' 'h' \
        | string replace -ra ' minutes?' 'm' \
        | string replace -a ', ' ' ')
    set -l now (date '+%a %d %b · %H:%M')
    set -l rail (set_color $frame)'│ '
    set -l sep (set_color $dim)' · '(set_color $txt)

    set -l W 64
    set -l p_user "USER:   $USER@$host"
    set -l p_sys "SYSTEM: $os · kernel $kern · fish $version"
    set -l p_time "TIME:   $now · UP: $up"
    set -l rail (set_color $frame)'│ '
    set -l end (set_color $frame)'│'(set_color normal)
    set -l sep (set_color $dim)' · '(set_color $txt)

    echo
    echo (set_color $frame)'┌─ '(set_color $clay)'[ SESSION ] '(set_color $frame)(string repeat -n (math $W - 16) '─')'┐'
    echo $rail(set_color $lbl)'USER:   '(set_color $txt)$USER(set_color $dim)'@'(set_color $txt)$host(string repeat -n (math $W - 3 - (string length --visible -- $p_user)) ' ')$end
    echo $rail(set_color $lbl)'SYSTEM: '(set_color $txt)$os$sep'kernel '$kern$sep'fish '$version(string repeat -n (math $W - 3 - (string length --visible -- $p_sys)) ' ')$end
    echo $rail(set_color $lbl)'TIME:   '(set_color $txt)$now$sep(set_color $lbl)'UP: '(set_color $txt)$up(string repeat -n (math $W - 3 - (string length --visible -- $p_time)) ' ')$end
    echo (set_color $frame)'└'(string repeat -n (math $W - 2) '─')'┘'
    set_color normal
end
