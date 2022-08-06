function _nvm_symlink_local

    test ! -d $nvm_data && command mkdir -p $nvm_data

    set --local existingVersionsDir $HOME/.nvm/versions/node

    if test -d $existingVersionsDir
        echo "Found existing node packages at $existingVersionsDir" >&2
        echo "Creating symlink to existing packages" >&2
        command ln -sf $existingVersionsDir/* $nvm_data
        echo "Found and linked:" >&2
        _nvm_list 
    else
        echo "No exisiting NVM Node package found. Skipping..." >&2
    end

end
