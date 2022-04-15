function _nvm_use_on_pwd_change \
    --on-variable nvm_use_on_pwd_change \
    --on-variable PWD \
    --description 'Use Node.js version specified by project automatically'

    if test "$nvm_use_on_pwd_change" = true
        nvm use 2>/tmp/_nvm_use_on_pwd_change.log
    end
end && _nvm_use_on_pwd_change
