set -g nvm_version 1.0.1

function nvm -a cmd -d "Node.js version manager"
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    set -g nvm_config $XDG_CONFIG_HOME/nvm
    set -g nvm_file .nvmrc
    set -q nvm_mirror; or set -g nvm_mirror "https://nodejs.org/dist"

    if test ! -d $nvm_config
        command mkdir -p $nvm_config
    end

    switch "$cmd"
        case ls list
            set -e argv[1]
            _nvm_ls $argv
        case use
            set -e argv[1]
            _nvm_use $argv
        case ""
            if isatty
                if set -l root (_nvm_find_up (pwd) $nvm_file)
                    read cmd <$root/$nvm_file
                end
            else
                read cmd
            end
            if not set -q cmd[1]
                echo "nvm: version or .nvmrc file missing" >&2
                _nvm_help >&2
                return 1
            end

            _nvm_use $cmd
        case {,-}-v{ersion,}
            echo "nvm version $nvm_version"
        case {,-}-h{elp,}
            _nvm_help
        case complete
            _nvm_complete "$nvm_config/index"
        case \*
            echo "nvm: unknown flag or command \"$cmd\"" >&2
            _nvm_help >&2
            return 1
    end
end

function _nvm_help
    echo "usage: nvm --help           Show this help"
    echo "       nvm --version        Show the current version of nvm"
    echo "       nvm ls [<regex>]     List available versions matching <regex>"
    echo "       nvm use <version>    Download <version> and modify PATH to use it"
    echo "       nvm                  Use version in .nvmrc (or stdin if not a tty)"
    echo "examples:"
    echo "       nvm use 12"
    echo "       nvm use lts"
    echo "       nvm use latest"
    echo "       nvm use dubnium"
    echo "       nvm ls '^1|9\$'"
    echo "       nvm ls 10"
    echo "       nvm <file"
end

function _nvm_complete -a index
    if test -s "$index"
        for alias in (command awk '
            $4 {
                for (i = split($4, alias, "|"); i; i--)
                    if (!seen[alias[i]]++) print alias[i]
            }
            $2 != "-" && !seen[$2]++ { print $2 } { print $1 }
        ' <$index)
            complete -xc nvm -n "__fish_seen_subcommand_from use" -a $alias
        end
    end
end

function _nvm_get_index
    set -l index "$nvm_config/index"
    set -q nvm_index_update_interval; or set -g nvm_index_update_interval 0

    if test ! -e $index -o (math (command date +%s) - $nvm_index_update_interval) -gt 120
         command curl -sS $nvm_mirror/index.tab | command awk -v OFS=\t '
            NR > 1 && !/^v0\.[1-9]\./ {
                split($1 = substr($1, 2), v, ".")
                is_latest = NR == 2
                alias = ($10 = tolower($10)) == "-" ? "" : "lts|"$10
                is_lts = alias != ""
                print $1, (/^0/ ? "-" : v[1]), v[1]"."v[2],
                    is_latest ? is_lts ? alias"|latest" : "latest" : is_lts ? alias : ""
            }
        ' >$index 2>/dev/null

        if test ! -s "$index"
            echo "nvm: invalid mirror index -- is \"$nvm_mirror\" a valid host?" >&2
            return 1
        end

        _nvm_complete $index
        set -g nvm_index_update_interval (command date +%s)
    end

    echo $index
end

function _nvm_ls -a query
    set -l index (_nvm_get_index); or return
    test -s "$nvm_config/version"; and read -l current <"$nvm_config/version"
    command awk -v current="$current" '
        $1 ~ /'"$query"'/ {
            gsub(/\|/, "/", $4)
            out[n++] = $1
            out[n++] = $4 ($1 == current ? ($4 ? "/" : "") "current" : "")
            pad = pad < length($1) ? length($1) : pad
        }
        END {
            for (i = n - 1; i > 0; i -= 2) {
                printf("%"pad"s    %s\n", out[i - 1] , out[i] ? "("out[i]")": "")
            }
        }
    ' <$index 2>/dev/null
end

function _nvm_resolve_version
    set -l index (_nvm_get_index); or return
    set -l ver (command awk -v ver="$argv[1]" '
        BEGIN {
            if (match(ver, /v[0-9]/)) gsub(/^[ \t]*v|[ \t]*$/, "", ver)
            if ((n = split(tolower(ver), a, "/")) > 3) exit
            for (ver = a[1]; n > 0; n--) {
                if (a[n] != "*" && a[n] != "latest" && (ver = a[n]) != "lts")
                    break
            }
        }
        ver == $1"" || ver == $2"" || ver == $3"" || $4 && ver ~ $4 {
            print $1
            exit
        }
    ' <$index 2>/dev/null)

    if not set -q ver[1]
        return 1
    end

    echo $ver
end

function _nvm_use
    set -l index (_nvm_get_index); or return
    set -l ver (_nvm_resolve_version $argv[1])

    if not set -q ver[1]
        echo "nvm: invalid version number or alias: \"$argv[1]\"" >&2
        return 1
    end

    if test ! -d "$nvm_config/$ver/bin"
        set -l os
        set -l arch
        set -l name "node-v$ver"
        set -l target "$nvm_config/$ver"
        switch (uname -s)
            case Linux
                set os linux
                switch (uname -m)
                    case x86_64
                        set arch x64
                    case armv6 armv6l
                        set arch armv6l
                    case armv7 armv7l
                        set arch armv7l
                    case armv8 armv8l
                        set arch arm64
                    case \*
                        set arch x86
                end
                set name "$name-linux-$arch.tar.gz"
            case Darwin
                set os darwin
                set arch x64
            case \*
                echo "nvm: OS not implemented -- request it on https://git.io/fish-nvm" >&2
                return 1
        end

        set -l name "node-v$ver-$os-$arch"
        set -l url $nvm_mirror/v$ver/$name

        echo "fetching $url" >&2
        command mkdir -p $target/$name

        if not command curl --fail --progress-bar $url.tar.gz | command tar -xzf- -C $target/$name
            command rm -rf $target
            echo "nvm: fetch error -- are you offline?" >&2
            return 1
        end

        command mv -f $target/$name/$name $nvm_config/$ver.
        command rm -rf $target
        command mv -f $nvm_config/$ver. $target
    end

    if test -s "$nvm_config/version"
        read -l last <"$nvm_config/version"
        if set -l i (contains -i -- "$nvm_config/$last/bin" $fish_user_paths)
            set -e fish_user_paths[$i]
        end
    end

    if set -l root (_nvm_find_up (pwd) $nvm_file)
        read -l line <$root/$nvm_file
        if test $ver != (_nvm_resolve_version $line)
            echo $argv[1] >$root/$nvm_file
        end
    end

    echo $ver >$nvm_config/version

    if not contains -- "$nvm_config/$ver/bin" $fish_user_paths
        set -U fish_user_paths "$nvm_config/$ver/bin" $fish_user_paths
    end
end

function _nvm_find_up -a path file
    if test -e "$path/$file"
        echo $path
    else if test "$path" != /
        _nvm_find_up (command dirname $path) $file
    else
        return 1
    end
end
