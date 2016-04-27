function __fin_version_which
    if test -s .finrc
        read -l v < .finrc

        if not set v (__fin_version_validate "$v")
            return 1
        end

        if not set v (__fin_version_query "$v")
            return 1
        end

        printf "%s\n" "$v"
    else
        if test ! -e "$fin_config/version"
            return 1
        end

        read -l v < "$fin_config/version"

        printf "%s\n" "$v"
    end
end
