function _nvm_version_deactivate --argument-names v
    test "$nvm_current_version" = "$v" && set --erase nvm_current_version
    set --local index (contains --index -- $nvm_data/$v/bin $PATH) &&
        set --erase PATH[$index]
end
