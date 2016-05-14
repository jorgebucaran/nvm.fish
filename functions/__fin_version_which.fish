function __fin_version_which
    if set -l rc_ver (__fin_read_finrc)
        if not set rc_ver (__fin_version_validate "$rc_ver")
            return 1
        end

        if not set rc_ver (__fin_version_query "$rc_ver")
            return 1
        end

        printf "%s\n" "$rc_ver"
    else
        if test ! -e "$fin_config/version"
            return 1
        end

        read -l v < "$fin_config/version"

        printf "%s\n" "$v"
    end
end
