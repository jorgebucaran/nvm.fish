function __fnm_read_fnmrc
    set -l fnmrc

    for f in .fnmrc .nvmrc .node-version
        if test -s "$f"
            set fnmrc "$f"
            break
        end
    end

    if test -z "$fnmrc"
        return 1
    end

    read -l v < "$fnmrc"

    if test "$v" = "lts/*"
        set v "lts"
    end

    printf "%s\n" $v
end
