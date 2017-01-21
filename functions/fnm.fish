function fnm -d "node.js version manager"
    set -l config_home "$XDG_CONFIG_HOME"

    if test -z "$config_home"
        set config_home ~/.config
    end

    if test -z "$fnm_config"
        if not source "$config_home/fish/conf.d/fnm.fish" ^ /dev/null
            echo "fnm: Internal error: fnm was not installed correctly." > /dev/stderr
            echo "fnm: I could not fnmd '$config_home/fish/conf.d/fnm.fish'." > /dev/stderr
            return 1
        end
    end

    if not command mkdir -p "$fnm_config"/{bin,versions} "$fnm_cache"/versions
        echo "fnm: I couldn't create the fnm configuration: $fnm_config" > /dev/stderr
        return 1
    end

    set -g fnm_version 1.8.1

    set -l cmd

    switch "$argv[1]"
        case -h --help help
            __fnm_usage > /dev/stderr
            return

        case -v --version
            echo "fnm v$fnm_version"
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

        case latest
            set cmd "use"
            if set -q argv[2]
                set -e argv[1]
                set argv[1] "latest-$argv[1]"
            end

        case -\*\*
            echo "fnm: '$argv[1]' is not a valid option." > /dev/stderr
            __fnm_usage > /dev/stderr
            return 1

        case \*
            set cmd "use"
    end

    switch "$cmd"
        case default
            if set -l rc_ver (__fnm_read_fnmrc)
                __fnm_use "$rc_ver"
            else
                set -l local_versions (__fnm_version_local)

                if test -z "$local_versions"
                    __fnm_usage > /dev/stderr
                    return 1
                end

                set -l menu_selected_index
                set -l menu_cursor_glyph (set_color -o white)"•"(set_color normal)
                set -l menu_hover_item_style -o white

                set -l sel_ver

                if test -s "$fnm_config/version"
                    read sel_ver < "$fnm_config/version"

                    if set -l index (contains --index -- "$sel_ver" $local_versions)
                        set menu_selected_index "$index"
                    end
                end

                menu $local_versions

                __fnm_use "$local_versions[$menu_selected_index]"
            end

        case use
            __fnm_use $argv

        case list
            __fnm_list $argv

        case remove
            if not set -q argv[1]
                if test -s "$fnm_config/version"
                    if __fnm_read_fnmrc > /dev/null
                        echo "fnm: You tried to run 'fnm rm' without arguments, but " > /dev/stderr
                        echo "     there is a .fnmrc file in the current directory." > /dev/stderr
                        echo > /dev/stderr
                        echo "Hint: Delete this file to disable automatic version" > /dev/stderr
                        echo "      switching in this directory." > /dev/stderr

                        return 1
                    else
                        read -l v < "$fnm_config/version"
                        set argv[1] "$v"
                    end
                end
            end

            for v in $argv
                __fnm_rm $v
            end
    end

    complete -c fnm --erase

    source "$config_home/fish/completions/fnm.fish" ^ /dev/null
end
