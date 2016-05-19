function __fin_run_bin_as -a name
    #
    # Remove after fish 2.3 is available
    #
    switch "$FISH_VERSION"
        case 2.2.0
            if test -z "$fin_cache"
                set -l config "$XDG_CONFIG_HOME"

                if test -z "$config"
                    set config ~/.config/fish/
                end

                set config "$config/conf.d/fin.fish"

                if test ! -s "$config"
                    exit
                end

                source "$config" ^ /dev/null
            end
    end
    #
    # Remove after fish 2.3 is available
    #

    set -e argv[1]

    set -l local_versions (__fin_version_local)
    set -l rc_ver
    set -l sel_ver

    if set rc_ver (__fin_read_finrc)
        if test -s "$fin_config/version"
            read sel_ver < "$fin_config/version"
        end

        if not fin "$rc_ver"
            return 1
        end

        read rc_ver < "$fin_config/version"
    end

    set -lx PATH $PATH
    set -l bin "$fin_config/bin"

    if test -s "$bin/node"
        set PATH "$bin" $PATH
    end

    if test "$name" = "node"
        command node $argv

    else if test "$name" = "npm"
        command npm $argv

    else
        echo "fin: Error: I don't know what is '$name'." > /dev/stderr
    end

    if test ! -z "$rc_ver"
        if not contains -- "$rc_ver" $local_versions
            fin rm "$rc_ver"
        end

        if test ! -z "$sel_ver"
            fin "$sel_ver"
        end
    end
end
