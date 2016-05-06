function __fin_read_finrc
    set -l finrc

    for f in .finrc .nvmrc .node-version
        if test -s "$f"
            set finrc "$f"
            break
        end
    end

    if test -z "$finrc"
        return 1
    end

    read -l v < "$finrc"

    printf "%s\n" $v
end
