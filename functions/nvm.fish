function nvm -a cmd -d "Node version manager"
    set --local ver "$argv[2..-1]"
    set --query nvm_mirror || set --global nvm_mirror https://nodejs.org/dist

    if test -z "$ver" && contains -- "$cmd" install use
        for file in .nvmrc .node-version
            set file (_nvm_find_up $PWD $file) && read ver <$file && break
        end
        if test -z "$ver"
            echo "nvm: Invalid version or missing \".nvmrc\" file" >&2
            return 1
        end
    end    

    test ! -d $nvm_data && command mkdir -p $nvm_data

    switch "$cmd"
        case -v --version
            echo "nvm, version $nvm_version"
        case "" -h --help
            echo "usage: nvm install <version>  Download and activate a version"
            echo "       nvm install            Install version from nearest .nvmrc file"
            echo "       nvm use <version>      Activate a version in the current shell"
            echo "       nvm use                Activate version from nearest .nvmrc file"
            echo "       nvm remove <version>   Remove an installed version"
            echo "       nvm current            Print currently-active version"
            echo "       nvm list               List installed versions"
            echo "       nvm list-remote        List versions available to install"
            echo "options:"
            echo "       -v or --version        Print nvm version"
            echo "       -h or --help           Print this help message"
        case install
            _nvm_index_update $nvm_mirror/index.tab $nvm_data/.index || return

            string match --entire --regex (_nvm_version_match $ver) <$nvm_data/.index | read ver alias

            if not set --query ver[1]
                echo "nvm: Invalid version number or alias: \"$argv[2..-1]\"" >&2
                return 1
            end

            if test ! -e $nvm_data/$ver
                set --local arch (uname -m)
                set --local os (string lower (uname -s))

                switch $os
                    case linux
                        switch $arch
                            case x86_64
                                set arch x64
                            case armv6 armv6l
                                set arch armv6l
                            case armv7 armv7l
                                set arch armv7l
                            case armv8 armv8l aarch64
                                set arch arm64
                            case \*
                                echo "nvm: Unsupported hardware architecture: \"$arch\"" >&2
                                return 1
                        end
                    case darwin
                        set arch x64
                    case \*
                        echo "nvm: Unsupported operating system: \"$os\"" >&2
                        return 1
                end

                set --local dir "node-$ver-$os-$arch"
                set --local url $nvm_mirror/$ver/$dir.tar.gz

                command mkdir -p $nvm_data/$ver

                echo -e "Installing Node \x1b[1m$ver\x1b[22m $alias"
                echo -e "Fetching \x1b[4m$url\x1b[24m\x1b[7m"

                if not command curl --progress-bar --location --show-error $url \
                    | command tar --extract --gzip --directory $nvm_data/$ver 2>/dev/null
                    command rm -rf $nvm_data/$ver
                    echo -e "\033[F\33[2K\x1b[0mnvm: Invalid mirror or host unavailable: \"$url\"" >&2
                    return 1
                end

                echo -en "\033[F\33[2K\x1b[0m"

                command mv $nvm_data/$ver/$dir/* $nvm_data/$ver
                command rm -rf $nvm_data/$ver/$dir
            end
           
            test "$nvm_current_version" != $ver && _nvm_version_activate $ver

            echo -e "Now using Node "(node --version)" "(command --search node)
        case use
            test $ver = default && set ver $nvm_default_version

            if test $ver = system && set ver (_nvm_current) && test system != $ver
                _nvm_version_deactivate $nvm_current_version
            else
                _nvm_list | string match --entire --regex (_nvm_version_match "$ver") | read ver __

                if not set --query ver[1]
                    echo "nvm: Node version not available or invalid version/alias: \"$argv[2..-1]\"" >&2
                    return 1
                end

                test "$nvm_current_version" != $ver && _nvm_version_activate $ver
            end

            echo -e "Now using Node "(node --version)" "(command --search node)

        case remove uninstall
            if test -z "$ver"
                echo "nvm: Not enough arguments for command: \"$cmd\"" >&2
                return 1
            end

            test "$ver" = default && set ver $nvm_default_version

            _nvm_list | string match --entire --regex (_nvm_version_match "$ver") | read ver __

            if not set -q ver[1]
                echo "nvm: Invalid version number or alias: \"$argv[2..-1]\"" >&2
                return 1
            end

            echo -e "Removing Node $ver "(command --search node)
            command rm -rf $nvm_data/$ver

            _nvm_version_deactivate $ver
        case current
            _nvm_current
        case ls list
            _nvm_list | _nvm_list_format (_nvm_current)
        case lsr {ls,list}-remote
            _nvm_index_update $nvm_mirror/index.tab $nvm_data/.index || return
            _nvm_list | command awk '
                FNR == NR {
                    is_local[$1]++
                    next
                } { print $0 (is_local[$1] ? " ✓" : "") }
            ' - $nvm_data/.index | _nvm_list_format (_nvm_current)
        case \*
            echo "nvm: Unknown flag or command: \"$cmd\" (see `nvm -h`)" >&2
            return 1
    end
end

function _nvm_find_up -a path file
    test -e "$path/$file" && echo $path/$file || begin
        test "$path" != / || return
        _nvm_find_up (command dirname $path) $file
    end
end

function _nvm_index_update -a mirror index
    command curl --show-error --location --silent $mirror | command awk -v OFS=\t '
        NR > 1 {
            print $1 (NR == 2  ? " latest" : $10 != "-" ? " lts/" tolower($10) : "")
        }
    ' > $index.temp && command mv $index.temp $index && return 
    
    command rm -f $index.temp
    echo "nvm: Invalid index or unavailable host: \"$mirror\"" >&2
    return 1
end

function _nvm_version_match -a ver
    # TODO: Make regex more strict.
    string lower $ver | \
        string replace --regex "\s*(node|latest)[/\s]*" "" | \
        string replace --regex "^(\d+)" "v\$1" | \
        string replace --regex "v(\d+|\d+\.\d+)\$" "v\$1." | \
        string escape --style=regex | \
        string replace --regex '^(\w+)$' '/$1' | \
        string replace --regex '/(lts|system)' '$1'
end

function _nvm_list_format -a current
    command awk -v current="$current" '
        {
            idx = i++
            versions[idx] = $1
            aliases[idx] = $2 " " $3
            padding = (len = length($1)) > padding ? len : padding
        }
        END {
            for (i = idx; i >= 0; i--) {
                printf((current == versions[i] ? " ▶ " : "   ") "%"padding"s %s\n", versions[i], aliases[i])
            }
        }
    '
end

function _nvm_current
    command --search --quiet node || return
    set --query nvm_current_version && echo $nvm_current_version || echo system
end