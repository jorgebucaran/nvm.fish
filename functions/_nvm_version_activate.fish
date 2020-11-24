function _nvm_version_activate -a ver
    _nvm_version_deactivate $nvm_current_version       
    set --global --export nvm_current_version $ver
    set --prepend PATH $nvm_data/$ver/bin
end