function __fnm_use -a v
    set v (__fnm_version_validate "$v")

    switch $status
        case 2
            echo "fnm: Versions under 0.10.0 are not supported at the moment." > /dev/stderr
            echo "Hint: If you'd like to support this feature visit: " > /dev/stderr
            echo "          <github.com/fisherman/fnm/issues>" > /dev/stderr
            return 1

        case 1
            echo "fnm: It seems '$v' is not a valid version number." > /dev/stderr
            echo "Hint: Examples of valid node versions:" > /dev/stderr
            echo "       v5.10.1" > /dev/stderr
            echo "        latest" > /dev/stderr
            echo "          0.12" > /dev/stderr
            echo "           lts" > /dev/stderr

            return 1
    end

    if test ! -e "$fnm_cache/index"
        if not __fnm_index_update
            echo "fnm: I could not fetch the remote index." > /dev/stderr
            echo "Hint: This is most likely a problem with http://nodejs.org" > /dev/stderr
            echo "      or a connection timeout. If the problem persists" > /dev/stderr
            echo "      open an issue in: <github.com/fisherman/fnm/issues>" > /dev/stderr

            return 1
        end
    end

    if not set v (__fnm_version_query "$v")
        echo "fnm: I couldn't fnmd '$v' in the version index." > /dev/stderr
        return 1
    end

    if test -s "$fnm_config/version"
        read -l sel_ver < "$fnm_config/version"

        if test "$v" = "$sel_ver"
            return
        end
    end

    if test ! -e "$fnm_config/versions/$v"
        if test ! -s "$fnm_cache/versions/$v/bin/node"
            if not __fnm_version_download "$v" "$fnm_cache/versions/$v"
                switch "$status"
                    case 2
                        set -l os (uname -s)
                        echo "fnm: '$os' is currently not supported. " > /dev/stderr
                        echo "Hint: To help us support your OS, please visit:" > /dev/stderr
                        echo "              <github.com/fisherman/fnm/issues>" > /dev/stderr

                    case 1
                        echo "fnm: I could not download '$v'" > /dev/stderr
                        echo "Hint: This could be a fetch error due to a bad connection" > /dev/stderr
                        echo "      or a bug in the extracting function. If the problem" > /dev/stderr
                        echo "      persists, visit: <github.com/fisherman/fnm/issues>" > /dev/stderr
                end

                return 1
            end
        end

        command touch "$fnm_config/versions/$v"
    end

    if not command cp -fR "$fnm_cache/versions/$v/bin/." "$fnm_config/bin" ^ /dev/null
        return 1
    end

    command cp -fR "$fnm_cache/versions/$v/lib/." "$fnm_config/lib"

    echo "$v" > "$fnm_config/version"

    set -l config_home "$XDG_CONFIG_HOME"

    if test -z "$config_home"
        set config_home ~/.config
    end

    source "$config_home/fish/completions/fnm.fish" ^ /dev/null
end
