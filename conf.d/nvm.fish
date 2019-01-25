function _nvm_uninstall -e nvm_uninstall
    if test -s "$nvm_config/version"
        read -l ver <$nvm_config/version
        if set -l i (contains -i -- "$nvm_config/$ver/bin" $fish_user_paths)
            set -e fish_user_paths[$i]
        end
        command rm -f $nvm_config/version
    end

    for name in (set -n | command awk '/^nvm_/')
        set -e "$name"
    end

    functions -e (functions -a | command awk '/^_nvm_/')
end
