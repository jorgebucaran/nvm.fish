function __fin_version_local
    set -l versions "$fin_config/versions"/*

    if test -z "$versions"
        return 1
    end

    printf "%s\n" $versions | sed 's|.*/||'
end
