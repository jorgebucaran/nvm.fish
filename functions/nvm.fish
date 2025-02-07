function nvm --description "Node version manager"
    for silent in --silent -s
        if set --local index (contains --index -- $silent $argv)
            set --erase argv[$index] && break
        end
        set --erase silent
    end

    set --local cmd $argv[1]
    set --local ver $argv[2]

    if set --query silent && ! set --query cmd[1]
        echo "nvm: Version number not specified (see nvm -h for usage)" >&2
        return 1
    end

    if ! set --query ver[1] && contains -- "$cmd" install use
        for file in .nvmrc .node-version
            set file (_nvm_find_up $PWD $file) && read ver <$file && break
        end

        if ! set --query ver[1]
            echo "nvm: Invalid version or missing \".nvmrc\" file" >&2
            return 1
        end
    end

    set --local their_version $ver

    switch "$cmd"
        case -v --version
            echo "nvm, version 2.2.17"
        case "" -h --help
            echo "Usage: nvm install <version>    Download and activate the specified Node version"
            echo "       nvm install              Install the version specified in the nearest .nvmrc file"
            echo "       nvm use <version>        Activate the specified Node version in the current shell"
            echo "       nvm use                  Activate the version specified in the nearest .nvmrc file"
            echo "       nvm list                 List installed Node versions"
            echo "       nvm list-remote          List available Node versions to install"
            echo "       nvm list-remote <regex>  List Node versions matching a given regex pattern"
            echo "       nvm current              Print the currently-active Node version"
            echo "       nvm uninstall <version>  Uninstall the specified Node version"
            echo "Options:"
            echo "       -s, --silent             Suppress standard output"
            echo "       -v, --version            Print the version of nvm"
            echo "       -h, --help               Print this help message"
            echo "Variables:"
            echo "       nvm_arch                 Override architecture, e.g. x64-musl"
            echo "       nvm_mirror               Use a mirror for downloading Node binaries"
            echo "       nvm_default_version      Set the default version for new shells"
            echo "       nvm_default_packages     Install a list of packages every time a Node version is installed"
            echo "       nvm_data                 Set a custom directory for storing nvm data"
            echo "Examples:"
            echo "       nvm install latest       Install the latest version of Node"
            echo "       nvm use 14.15.1          Use Node version 14.15.1"
            echo "       nvm use system           Activate the system's Node version"

        case install
            _nvm_index_update

            string match --entire --regex -- (_nvm_version_match $ver) <$nvm_data/.index | read ver alias

            if ! set --query ver[1]
                echo "nvm: Invalid version number or alias: \"$their_version\"" >&2
                return 1
            end

            if test ! -e $nvm_data/$ver
                set --local os (command uname -s | string lower)
                set --local ext tar.gz
                set --local arch (command uname -m)

                switch $os
                    case aix
                        set arch ppc64
                    case sunos
                    case linux
                    case darwin
                    case {MSYS_NT,MINGW\*_NT}\*
                        set os win
                        set ext zip
                    case \*
                        echo "nvm: Unsupported operating system: \"$os\"" >&2
                        return 1
                end

                switch $arch
                    case i\*86
                        set arch x86
                    case x86_64
                        set arch x64
                    case arm64
                        string match --regex --quiet "v(?<major>\d+)" $ver
                        if test "$os" = darwin -a $major -lt 16
                            set arch x64
                        end
                    case armv6 armv6l
                        set arch armv6l
                    case armv7 armv7l
                        set arch armv7l
                    case armv8 armv8l aarch64
                        set arch arm64
                end

                set --query nvm_arch && set arch $nvm_arch

                set --local dir "node-$ver-$os-$arch"
                set --local url $nvm_mirror/$ver/$dir.$ext

                command mkdir -p $nvm_data/$ver

                if ! set --query silent
                    echo -e "Installing Node \x1b[1m$ver\x1b[22m $alias"
                    echo -e "Fetching \x1b[4m$url\x1b[24m\x1b[7m"
                end

                if ! command curl -q $silent --progress-bar --location $url |
                        command tar --extract --gzip --directory $nvm_data/$ver 2>/dev/null
                    command rm -rf $nvm_data/$ver
                    echo -e "\033[F\33[2K\x1b[0mnvm: Invalid mirror or host unavailable: \"$url\"" >&2
                    return 1
                end

                set --query silent || echo -en "\033[F\33[2K\x1b[0m"

                if test "$os" = win
                    command mv $nvm_data/$ver/$dir $nvm_data/$ver/bin
                else
                    command mv $nvm_data/$ver/$dir/* $nvm_data/$ver
                    command rm -rf $nvm_data/$ver/$dir
                end
            end

            if test $ver != "$nvm_current_version"
                set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version
                _nvm_version_activate $ver

                set --query nvm_default_packages[1] && npm install --global $silent $nvm_default_packages
            end

            set --query silent || printf "Now using Node %s (npm %s) %s\n" (_nvm_node_info)
        case use
            test $ver = default && set ver $nvm_default_version
            _nvm_list | string match --entire --regex -- (_nvm_version_match $ver) | read ver __

            if ! set --query ver[1]
                echo "nvm: Can't use Node \"$their_version\", version must be installed first" >&2
                return 1
            end

            if test $ver != "$nvm_current_version"
                set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version
                test $ver != system && _nvm_version_activate $ver
            end

            set --query silent || printf "Now using Node %s (npm %s) %s\n" (_nvm_node_info)
        case uninstall
            if test -z "$ver"
                echo "nvm: Not enough arguments for command: \"$cmd\"" >&2
                return 1
            end

            test $ver = default && test ! -z "$nvm_default_version" && set ver $nvm_default_version

            _nvm_list | string match --entire --regex -- (_nvm_version_match $ver) | read ver __

            if ! set -q ver[1]
                echo "nvm: Node version not installed or invalid: \"$their_version\"" >&2
                return 1
            end

            set --query silent || printf "Uninstalling Node %s %s\n" $ver (string replace ~ \~ "$nvm_data/$ver/bin/node")

            _nvm_version_deactivate $ver

            command rm -rf $nvm_data/$ver
        case current
            _nvm_current
        case ls list
            _nvm_list | _nvm_list_format (_nvm_current) $argv[2]
        case lsr {ls,list}-remote
            _nvm_index_update || return
            _nvm_list | command awk '
                FILENAME == "-" && (is_local[$1] = FNR == NR) { next } {
                    print $0 (is_local[$1] ? " ✓" : "")
                }
            ' - $nvm_data/.index | _nvm_list_format (_nvm_current) $argv[2]
        case \*
            echo "nvm: Unknown command or option: \"$cmd\" (see nvm -h for usage)" >&2
            return 1
    end
end

function _nvm_find_up --argument-names path file
    test -e "$path/$file" && echo $path/$file || begin
        test ! -z "$path" || return
        _nvm_find_up (string replace --regex -- '/[^/]*$' "" $path) $file
    end
end

function _nvm_version_match --argument-names ver
    string replace --regex -- '^v?(\d+|\d+\.\d+)$' 'v$1.' $ver |
        string replace --filter --regex -- '^v?(\d+)' 'v$1' |
        string escape --style=regex || string lower '\b'$ver'(?:/\w+)?$'
end

function _nvm_list_format --argument-names current regex
    command awk -v current="$current" -v regex="$regex" '
        $0 ~ regex {
            aliases[versions[i++] = $1] = $2 " " $3
            pad = (n = length($1)) > pad ? n : pad
        }
        END {
            if (!i) exit 1
            while (i--)
                printf((current == versions[i] ? " ▶ " : "   ") "%"pad"s %s\n",
                    versions[i], aliases[versions[i]])
        }
    '
end

function _nvm_current
    command --search --quiet node || return
    set --query nvm_current_version && echo $nvm_current_version || echo system
end

function _nvm_node_info
    set --local npm_path (string replace bin/npm-cli.js "" (realpath (command --search npm)))
    test -f $npm_path/package.json || set --local npm_version_default (command npm --version)
    command node --eval "
        console.log(process.version)
        console.log('$npm_version_default' ? '$npm_version_default': require('$npm_path/package.json').version)
        console.log(process.execPath)
    " | string replace -- ~ \~
end
