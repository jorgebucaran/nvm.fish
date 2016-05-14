complete -xc fin -d "node.js version manager" -a "\t"
complete -xc fin -s h -l help -d "Show usage help"
complete -xc fin -s v -l version -d "Show version information"
complete -xc fin -n "__fish_use_subcommand" -a use -d "Select version"
complete -xc fin -n "__fish_use_subcommand" -a rm -d "Remove version"
complete -xc fin -n "__fish_use_subcommand" -a ls -d "List version info"

set -l lts
set -l latest

if test -e "$fin_cache/index"
    set lts (__fin_version_query lts)
    set latest (__fin_version_query latest)
end

if set -l versions (__fin_version_local)
    for ver in $versions
        set -l info

        if test "$latest" = "$ver"
            set info "latest"

        else if test "$lts" = "$ver"
            set info "lts"
        end

        complete -xc fin -a "$ver" -d "$info"
    end
end
