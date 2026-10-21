if status is-interactive
    # secrets (api keys etc) in a file with 600 perms, don't commit
    if test -f ~/.config/secrets/env
        for line in (string match -rv '^\s*(#|$)' < ~/.config/secrets/env)
            set -l kv (string split -m1 = $line)
            if test (count $kv) -eq 2
                set -gx (string trim $kv[1]) (string trim $kv[2])
            end
        end
    end

    # prompt and smart navigation
    starship init fish | source
    zoxide init fish | source

    # aliases
    alias ls="eza --icons"
    alias cd="z"
    alias du="dust"
    alias ps="procs"
    alias ff="fastfetch"
    alias cat="bat --plain"   # no pager so the output doesn't get stuck
    alias b="bat"             # quick view with highlighting
    alias tty="tty-clock -c -C 6"
    alias pipes="pipes.sh -t 0 -p 3 -R -c 10 -c 3 -c 8 -f 60"
    alias wp="wallpaper"        # wallpaper switching: wp / wp list / wp next / wp random
    # lava lamp: truecolor gradient green → teal
    alias lava="lavat -g -c d87756 -k e8a838"

    # Bluetooth / Wi-Fi (TUI)
    alias bt="bluetuith"
    alias wf="env NEWT_COLORS='root=lightgray,black border=brightblue,black window=lightgray,black title=yellow,black button=lightgray,black actbutton=black,yellow checkbox=brightblue,black actcheckbox=yellow,black entry=lightgray,black label=lightgray,black listbox=lightgray,black actlistbox=black,yellow helpline=gray,black roottext=lightgray,black' nmtui"
end

fish_add_path /home/anaidyss/go/bin

function eza
    tput rmam  # disable line wrapping (lines get cut off at the window edge)
    command eza -l --tree --icons $argv
    tput smam  # re-enable line wrapping for normal terminal behavior
end

function ll
    tput rmam
    command eza -la --icons $argv
    tput smam
end

fish_add_path /home/anaidyss/.spicetify
