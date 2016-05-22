function __fnm_version_query -a v
    command awk -v v="$v" '

        (v == "latest" && NR == 2) || (v == "lts" && $10 != "-" && NR > 1) {
            sub(/^v/, "", $1)
            result = $1
            exit
        }

        {
            sub(/^v/, "", $1)

            if ($1 ~ "^"v) {
                result = $1
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

    ' < "$fnm_cache/index"
end
