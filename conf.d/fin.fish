set -l config_home "$XDG_CONFIG_HOME"
set -l cache_home "$XDG_CACHE_HOME"

if test -z "$config_home"
    set config_home ~/.config
end

if test -z "$cache_home"
    set cache_home ~/.cache
end

if test -z "$fin_config"
    set -g fin_config "$config_home/fin"
end

if test -z "$fin_cache"
    set -g fin_cache "$cache_home/fin"
end
