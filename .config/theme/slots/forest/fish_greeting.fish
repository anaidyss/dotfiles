function fish_greeting --description "Forest greeting in the Forest palette"
    set -l nick anaidyss
    set -l host (hostname)
    set -l dim 64766a
    set -l txt cddbd0
    set -l teal 59c2a5
    set -l amber e3c078

    # Gradient banner: green → teal
    set -l grad a6e3a1 97dca2 87d6a3 78cfa3 68c9a4 59c2a5
    set -l art (figlet -f slant $nick)
    set -l i 1
    for line in $art
        if test $i -le (count $grad)
            set_color $grad[$i]
        else
            set_color $grad[-1]
        end
        echo $line
        set i (math $i + 1)
    end
    set_color normal

    # System info
    set -l pretty (grep '^PRETTY_NAME=' /etc/os-release | cut -d'=' -f2- | tr -d '"')
    set -l os (string replace ' Linux' '' -- (string replace -r ' \(.*\)' '' $pretty))
    set -l kern (uname -r | string replace -r -- '-.*' '')
    set -l up (uptime -p | string replace -r '^up ' '' \
        | string replace -ra ' days?' 'd' \
        | string replace -ra ' hours?' 'h' \
        | string replace -ra ' minutes?' 'm' \
        | string replace -a ', ' ' ')
    set -l now (date '+%a %d %b · %H:%M')
    set -l sep (set_color $dim)' · '(set_color $txt)

    echo
    echo (set_color $teal)(set_color $txt)' '$nick(set_color $dim)'@'(set_color $txt)$host
    echo (set_color $teal)(set_color $txt)' '$os$sep'kernel '$kern$sep'fish '$version
    echo (set_color $amber)(set_color $txt)' '$now$sep(set_color $amber)(set_color $txt)' '$up
    set_color normal
end
