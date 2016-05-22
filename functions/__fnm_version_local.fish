function __fnm_version_local
    set -l versions "$fnm_config/versions"/*

    if test -z "$versions"
        return 1
    end

    printf "%s\n" $versions | sed 's|.*/||'
end
