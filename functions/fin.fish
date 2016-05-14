function fin
    set -l config_home "$XDG_CONFIG_HOME"

    if test -z "$config_home"
        set config_home ~/.config
    end

    if test -z "$fin_config"
        if not source "$config_home/fish/conf.d/fin.fish" ^ /dev/null
            echo "fin: Internal error: fin was not installed correctly." > /dev/stderr
            echo "fin: I could not find '$config_home/fish/conf.d/fin.fish'." > /dev/stderr
            return 1
        end
    end

    if not command mkdir -p "$fin_config"/{bin,versions} "$fin_cache"/versions
        echo "fin: I couldn't create the fin configuration: $fin_config" > /dev/stderr
        return 1
    end

    set -g fin_version 1.6.1

    set -l cmd

    switch "$argv[1]"
        case -h --help
            __fin_usage > /dev/stderr
            return

        case -v --version
            echo "fin v$fin_version"
            return

        case u use -- ""
            set -e argv[1]

            if test -z "$argv"
                set cmd "default"
            else
                set cmd "use"
            end

        case l ls list
            set -e argv[1]
            set cmd "list"

        case r rm remove
            set -e argv[1]
            set cmd "remove"
            if not set -q argv[1] and test -s "$fin_config/version"
                read -l version_current < "$fin_config/version"
                set argv[1] $version_current
            end

        case latest
            set cmd "use"
            if set -q argv[2]
                set -e argv[1]
                set argv[1] "latest-$argv[1]"
            end

        case -\*\*
            echo "fin: '$argv[1]' is not a valid option." > /dev/stderr
            __fin_usage > /dev/stderr
            return 1

        case \*
            set cmd "use"
    end

    switch "$cmd"
        case default
            if set -l finrc_ver (__fin_read_finrc)
                __fin_use "$finrc_ver"
            else
                set -l local_versions (__fin_version_local)

                if test -z "$local_versions"
                    echo "fin: It seems no versions are installed yet." > /dev/stderr
                    return 1
                end

                set -l menu_selected_index
                set -l menu_cursor_glyph (set_color -o white)"•"(set_color normal)
                set -l menu_hover_item_style -o white

                set -l current_version

                if test -s "$fin_config/version"
                    read current_version < "$fin_config/version"

                    if set -l index (contains --index -- "$current_version" $local_versions)
                        set menu_selected_index "$index"
                    end
                end

                menu $local_versions

                __fin_use "$local_versions[$menu_selected_index]"
            end

        case use
            __fin_use $argv

        case list
            __fin_list $argv

        case remove
            for v in $argv
                __fin_rm $v
            end
    end

    complete -c fin --erase

    source "$config_home/fish/completions/fin.fish" ^ /dev/null
end
