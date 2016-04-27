function __fin_version_query -a v
    command awk -v v="$v" '

        (NR == 2 && "latest" == v) || (NR > 1 && "-" != $10 && "lts" == v) {
            sub(/^v/, "", $1)
            result = $1
            exit
        }

        {
            sub(/^v/, "", $1)

            if ($1 == v) {
                result = v
                exit
            }
        }

        END {
            if (result == "") {
                print(v)
                exit 1
            }

            print(result)
        }

    ' < "$fin_cache/index"
end
