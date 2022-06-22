function _nvm_version_deactivate --argument-names ver
    test "$nvm_current_version" = "$ver" && set --erase nvm_current_version
    set --local index (contains --index -- $nvm_data/$ver/bin $PATH) &&
        set --erase PATH[$index]
end
