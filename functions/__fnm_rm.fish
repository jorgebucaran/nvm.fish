function __fnm_rm -a v
    set v (__fnm_version_validate "$v")

    switch $status
        case 2
            echo "fnm: Versions under 0.10.0 are not supported at the moment." > /dev/stderr
            echo "Hint: If you'd like to support this feature visit: " > /dev/stderr
            echo "          <github.com/fisherman/fnm/issues>" > /dev/stderr
            return 1

        case 1
            echo "fnm: '$v' is not a valid version number." > /dev/stderr
            return 1
    end

    if test ! -e "$fnm_cache/index"
        if not __fnm_index_update
            echo "fnm: I could not fetch the remote index." > /dev/stderr
            echo "Hint: This is most likely a problem with http://nodejs.org" > /dev/stderr
            echo "      or a connection timeout. If the the problem persists" > /dev/stderr
            echo "      visit: <github.com/fisherman/fnm/issues>" > /dev/stderr

            return 1
        end
    end

    if not set v (__fnm_version_query "$v")
        echo "fnm: I couldn't fnmd '$v' in the version index." > /dev/stderr
        return 1
    end

    if test ! -e "$fnm_config/versions/$v"
        echo "fnm: It seems '$v' is not installed." > /dev/stderr

        if set -l rc_ver (__fnm_read_fnmrc)
            if test "$rc_ver" = "$v"
                echo "Hint: Delete any existing .fnmrc to disable automatic" > /dev/stderr
                echo "      version switching in the current directory." > /dev/stderr
            end
        end

        return 1
    end

    command rm -f "$fnm_config/versions/$v"

    if test -s "$fnm_config/version"
        read -l sel_ver < "$fnm_config/version"

        if test "$sel_ver" = "$v"
            fish -c "
                command rm -f '$fnm_config/version'
                command rm -f '$fnm_config/bin/node'
                command rm -f '$fnm_config/bin/npm'
                command rm -rf '$fnm_config/lib'
            " &

            await (last_job_id -l)
        end
    end

    return 0
end
