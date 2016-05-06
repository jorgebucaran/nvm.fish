function __fin_version_which
    if set -l finrc_ver (__fin_read_finrc)
        if not set finrc_ver (__fin_version_validate "$finrc_ver")
            return 1
        end

        if not set finrc_ver (__fin_version_query "$finrc_ver")
            return 1
        end

        printf "%s\n" "$finrc_ver"
    else
        if test ! -e "$fin_config/version"
            return 1
        end

        read -l v < "$fin_config/version"

        printf "%s\n" "$v"
    end
end
