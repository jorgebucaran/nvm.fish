function __fnm_list
    if not __fnm_index_update
        echo "fnm: I could not fetch the remote index." > /dev/stderr
        return 1
    end

    if test ! -z "$argv"
        for v in $argv
            if test ! -d "$fnm_cache/versions/$v"
                continue
            end

            printf "%s\n" "$fnm_cache/versions/$v"
        end

        return
    end

    set -l ver_which (__fnm_version_which)
    set -l ver_available (__fnm_version_local)

    command awk -v ver_which="$ver_which" -v ver_available_str="$ver_available" '

        function version_is_available(v,   i) {
            for (i = 1; i <= number_of_versions_available; i++) {
                if (ver_available[i] == v) {
                    return 1
                }
            }

            return 0
        }

        BEGIN {
            number_of_versions_available = split(ver_available_str, ver_available, " ")
        }

        {
            if (NR != 1) {
                sub(/^v/, "", $1)
                versions[++n] = $1
            }
        }

        END {
            for (i = n; i > 0; i--) {
                v = versions[i]

                if (ver_which == v) {
                    print(" • " v)

                } else if (version_is_available(v)) {
                    print(" - " v)

                } else {
                    print("   " v)
                }
            }
        }

    ' < "$fnm_cache/index"
end
