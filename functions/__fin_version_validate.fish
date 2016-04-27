function __fin_version_validate -a v
    printf "%s\n" "$v" | command awk '

        {
            sub(/^v/, "", $0)
        }

        /^[0-9]+$/ {
            $0 = $0 ".0.0"
        }

        /^[0-9]+\.[0-9]+$/ {
            $0 = $0 ".0"
        }

        /^lts$|^latest$|^[0-9]+\.[0-9]+\.[0-9]+$/ {
            ok = 1
        }

        {
            print($0)
            exit !ok
        }

    '
end
