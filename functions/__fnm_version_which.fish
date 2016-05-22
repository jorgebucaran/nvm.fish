function __fnm_version_which
    if set -l rc_ver (__fnm_read_fnmrc)
        if not set rc_ver (__fnm_version_validate "$rc_ver")
            return 1
        end

        if not set rc_ver (__fnm_version_query "$rc_ver")
            return 1
        end

        printf "%s\n" "$rc_ver"
    else
        if test ! -e "$fnm_config/version"
            return 1
        end

        read -l v < "$fnm_config/version"

        printf "%s\n" "$v"
    end
end
