function __fin_version_validate -a v
    printf "%s\n" "$v" | command awk '

        !/^v$/ {
            sub(/^v/, "", $0)
        }

        /^0\.[1-9](\.[0-9]+)?$/ {
            print($0)
            exit 2
        }

        /^lts$|^latest$|^[0-9]+(\.[0-9]+(\.[0-9]+)?)?$/ {
            ok = 1
        }

        /^latest-?v?[0-9]+(\.[0-9]+(\.[0-9]+)?)?(\.?x)?$/ {
            if (match($0, /[0-9]+(\.[0-9]+(\.[0-9]+)?)?/)) {
                $0 = ok = substr($0, RSTART, RLENGTH)
            }
        }

        {
            print($0)
            exit (ok == "")
        }

    '
end
