set -g nvm_version 1.1.0

set --query XDG_DATA_HOME \
    && set --global nvm_data $XDG_DATA_HOME/nvm \
    || set --global nvm_data ~/.local/share/nvm

if set --query nvm_default_version && not set --query nvm_current_version
    nvm use $nvm_default_version >/dev/null
end

function _nvm_uninstall -e nvm_uninstall
    # command rm -rf $nvm_data
    
    set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version

    for var in nvm_{version,current_version,default_node,data}
        set --erase $var
    end

    complete --erase --command nvm
    functions --erase (functions --all | string match --entire --regex "^_nvm_")
end