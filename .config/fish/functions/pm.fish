function pm --description "Toggle performance (1) or power-saver (0) mode"
    switch $argv[1]
        case 1
            if type -q powerprofilesctl
                powerprofilesctl set performance
            else
                echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
            end
            echo (set_color a6e3a1)" Power mode: PERFORMANCE (1)"(set_color normal)

        case 0
            if type -q powerprofilesctl
                powerprofilesctl set power-saver
            else
                echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null
            end
            echo (set_color 89b4fa)"󰌪 Power mode: POWER-SAVER (0)"(set_color normal)

        case ""
            if type -q powerprofilesctl
                echo "Current mode: "(set_color a6e3a1)(powerprofilesctl get)(set_color normal)
            else
                echo "Current governor: "(set_color a6e3a1)(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)(set_color normal)
            end

        case '*'
            echo (set_color f38ba8)"Usage: pm 1 (performance) | pm 0 (powersave)"(set_color normal)
    end
end
