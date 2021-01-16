set --query XDG_DATA_HOME &&
    set --global nvm_data $XDG_DATA_HOME/nvm ||
    set --global nvm_data ~/.local/share/nvm
set --query nvm_mirror[1] || set --global nvm_mirror https://nodejs.org/dist

function _nvm_install --on-event nvm_install
    test ! -d $nvm_data && command mkdir -p $nvm_data
    echo "Downloading the Node distribution index for the first time..." 2>/dev/null
    _nvm_index_update $nvm_mirror/index.tab $nvm_data/.index
end

function _nvm_uninstall --on-event nvm_uninstall
    command rm -rf $nvm_data

    set --query nvm_current_version && _nvm_version_deactivate $nvm_current_version

    set --names | string replace --filter --regex -- "^nvm" "set --erase nvm" | source
    functions --erase (functions --all | string match --entire --regex -- "^_nvm_")
end

status is-interactive &&
    set --query nvm_default_version && ! set --query nvm_current_version &&
    nvm use $nvm_default_version >/dev/null
