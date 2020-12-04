function _nvm_version_activate -a v
    set --global --export nvm_current_version $v
    set --prepend PATH $nvm_data/$v/bin
end