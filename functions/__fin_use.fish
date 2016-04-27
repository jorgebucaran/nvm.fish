function __fin_use -a v
    if not set v (__fin_version_validate "$v")
        echo "fin: It seems '$v' is not a valid version number." > /dev/stderr
        echo > /dev/stderr
        echo "Hint: Examples of valid node versions:" > /dev/stderr
        echo "       v5.10.1" > /dev/stderr
        echo "        latest" > /dev/stderr
        echo "          0.12" > /dev/stderr
        echo "           lts" > /dev/stderr

        return 1
    end

    if test ! -e "$fin_cache/index"
        if not __fin_index_update
            echo "fin: I could not fetch the remote index." > /dev/stderr
            echo > /dev/stderr
            echo "Hint: This is most likely a problem with http://nodejs.org" > /dev/stderr
            echo "      or a connection timeout. If the the problem persists" > /dev/stderr
            echo "      open an issue in: <github.com/fisherman/fin/issues>" > /dev/stderr

            return 1
        end
    end

    if not set v (__fin_version_query "$v")
        echo "fin: I couldn't find '$v' in the version index." > /dev/stderr
        return 1
    end

    if test -s "$fin_config/version"
        read -l version_current < "$fin_config/version"

        if test "$v" = "$version_current"
            return
        end
    end

    if test ! -s "$fin_config/versions/$v/node"
        if test ! -s "$fin_cache/versions/$v/bin/node"
            if not __fin_version_download "$v" "$fin_cache/versions/$v"
                switch "$status"
                    case 2
                        set -l os (uname -s)
                        echo "fin: '$os' is currently not supported. " > /dev/stderr
                        echo "Hint: To help us support your OS, please go to:" > /dev/stderr
                        echo "              <github.com/fisherman/fin/issues>" > /dev/stderr

                    case 1
                        echo "fin: I could not download '$v'" > /dev/stderr
                        echo "Hint: This could be a fetch error due to a bad connection" > /dev/stderr
                        echo "      or a bug in the extracting function. If the problem" > /dev/stderr
                        echo "      persists, go to: <github.com/fisherman/fin/issues>" > /dev/stderr
                end

                return 1
            end
        end

        command mkdir -p "$fin_config/versions/$v"
        command cp -f "$fin_cache/versions/$v/bin/node" "$fin_config/versions/$v/node"
        command cp -rf "$fin_cache/versions/$v/lib" "$fin_config/versions/$v/lib"
    end

    if test -s "$fin_config/versions/$v/node"
        command ln -sf "$fin_config/versions/$v/node" "$fin_config/bin/node"
        command ln -sf "$fin_config/versions/$v/lib/node_modules/npm/bin/npm-cli.js" "$fin_config/bin/npm"
        echo "$v" > "$fin_config/version"
    end
end
