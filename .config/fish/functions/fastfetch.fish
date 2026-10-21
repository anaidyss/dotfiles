function fastfetch --wraps fastfetch --description "fastfetch with closed boxes (Graphite theme)"
    if test (count $argv) -eq 0; and test (cat ~/.config/theme/current 2>/dev/null) = graphite
        command fastfetch --pipe false | ~/.local/bin/ff-box
    else
        command fastfetch $argv
    end
end
