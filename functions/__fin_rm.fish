function __fin_rm -a v
    if not set v (__fin_version_validate "$v")
        echo "fin: It seems '$v' is not a valid version number." > /dev/stderr
        return 1
    end

    if test ! -e "$fin_cache/index"
        if not __fin_index_update
            echo "fin: I could not fetch the remote index." > /dev/stderr
            echo > /dev/stderr
            echo "Hint: This is most likely a problem with http://nodejs.org" > /dev/stderr
            echo "      or a connection timeout. If the the problem persists" > /dev/stderr
            echo "      go to: <github.com/fisherman/fin/issues>" > /dev/stderr

            return 1
        end
    end

    if not set v (__fin_version_query "$v")
        echo "fin: I couldn't find '$v' in the version index." > /dev/stderr
        return 1
    end

    if test ! -e "$fin_config/versions/$v"
        echo "fin: It seems '$v' is not installed." > /dev/stderr

        if test -s .finrc
            read -l finrc_ver < .finrc

            if test "$finrc_ver" = "$v"
                echo "Hint: If you want to disable your .finrc file, just delete it." > /dev/stderr
            end
        end

        return 1
    end

    command rm -f "$fin_config/versions/$v"

    if test -s "$fin_config/version"
        read -l current_version < "$fin_config/version"

        if test "$current_version" = "$v"
            fish -c "
                command rm -f '$fin_config/version'
                command rm -f '$fin_config/bin/node'
                command rm -f '$fin_config/bin/npm'
                command rm -rf '$fin_config/lib'
            " &

            await (last_job_id -l)
        end
    end
end
