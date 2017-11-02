function __fnm_run_bin_as -a name
    #
    # Remove after fish 2.3 is available
    #
    switch "$FISH_VERSION"
        case 2.2.0
            if test -z "$fnm_cache"
                set -l config "$XDG_CONFIG_HOME"

                if test -z "$config"
                    set config ~/.config/fish/
                end

                set config "$config/conf.d/fnm.fish"

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

    set -l local_versions (__fnm_version_local)
    set -l rc_ver
    set -l sel_ver

    if set rc_ver (__fnm_read_fnmrc)
        if not fnm "$rc_ver"
            return 1
        end
    else if test -s "$fnm_config/version"
        read sel_ver < "$fnm_config/version"
        read rc_ver < "$fnm_config/version"
    end

    set -lx PATH $PATH
    set -l bin "$fnm_config/bin"

    if test -s "$bin/node"
        set PATH "$bin" $PATH
    end

    if test "$name" = "node"
        command node $argv
        set command_status $status

    else if test "$name" = "npm"
        command npm $argv
        set command_status $status

    else
        echo "fnm: Error: I don't know what is '$name'." > /dev/stderr
        set command_status 1
    end

    if test ! -z "$rc_ver"
        if not contains -- "$rc_ver" $local_versions
            fnm rm "$rc_ver"
        end

        if test ! -z "$sel_ver"
            fnm "$sel_ver"
        end
    end

    return $command_status
end
