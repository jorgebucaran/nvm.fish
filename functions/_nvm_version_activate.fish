function _nvm_version_activate --argument-names ver
    set --global --export nvm_current_version $ver
    set --prepend PATH $nvm_data/$ver/bin
end
