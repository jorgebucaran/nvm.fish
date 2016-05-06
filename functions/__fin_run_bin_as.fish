function __fin_run_bin_as -a name
    set -e argv[1]

    set -l local_versions (__fin_version_local)
    set -l finrc_version
    set -l current_version

    if set finrc_version (__fin_read_finrc)
        if test -s "$fin_config/version"
            read current_version < "$fin_config/version"
        end

        if not fin "$finrc_version"
            return 1
        end

        read finrc_version < "$fin_config/version"
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

    if test ! -z "$finrc_version"
        if not contains -- "$finrc_version" $local_versions
            fin rm "$finrc_version"
        end

        if test ! -z "$current_version"
            fin "$current_version"
        end
    end
end
