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

# Adds locally installed NodeJS npm binary executable modules to the path
# (stolen from https://github.com/oh-my-fish/plugin-node) 

if not type -q npm
  if test -d /usr/local/share/npm/bin
    if not contains /usr/local/share/npm/bin $PATH
      set PATH /usr/local/share/npm/bin $PATH
    end
  else if test -n "$NPM_DIR"; and test -d $NPM_DIR
    if not contains $NPM_DIR $PATH
      set PATH $NPM_DIR $PATH
    end
  else
    echo "plugin-node: npm is unavailable, either install it or set $NPM_DIR"
    echo "             in the config.fish file: set NPM_DIR /path/to/npm/dir"
  end
end

if not contains ./node_modules/.bin $PATH
  set PATH ./node_modules/.bin $PATH
end
