#
# Remove after fish 2.3 is available
#
switch "$FISH_VERSION"
    case 2.2.0
        if test -z "$fin_cache"
            set -l config "$XDG_CONFIG_HOME"

            if test -z "$config"
                set config ~/.config/fish/
            end

            set config "$config/conf.d/fin.fish"

            if test ! -s "$config"
                exit
            end

            source "$config" ^ /dev/null
        end
end
#
# Remove after fish 2.3 is available
#

source ~/.config/fish/conf.d/fin.fish

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
else
    complete -xc fin -a "\t"
end
