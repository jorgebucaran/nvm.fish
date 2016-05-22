set -l config_home "$XDG_CONFIG_HOME"
set -l cache_home "$XDG_CACHE_HOME"

if test -z "$config_home"
    set config_home ~/.config
end

if test -z "$cache_home"
    set cache_home ~/.cache
end

if test -z "$fnm_config"
    set -g fnm_config "$config_home/fnm"
end

if test -z "$fnm_cache"
    set -g fnm_cache "$cache_home/fnm"
end

if test -d "$fnm_config/bin"
    if not contains -- "$fnm_config/bin" $PATH
        set PATH "$fnm_config/bin" $PATH
    end
end
