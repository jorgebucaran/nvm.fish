set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
set -g nvm_bin_path $XDG_CONFIG_HOME/nvm/bin

if not contains $nvm_bin_path $PATH
    set PATH $nvm_bin_path $PATH
end

function _nvm_uninstall -e nvm_uninstall
    if test -s "$nvm_config/version"
        command rm -f $nvm_config/version
    end

    for name in (set -n | command awk '/^nvm_/')
        set -e "$name"
    end

    functions -e (functions -a | command awk '/^_nvm_/')
end
