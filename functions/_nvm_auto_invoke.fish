function _nvm_auto_invoke \
    --on-variable PWD \
    --description 'Use Node.js version specified by project automatically'

    if set --query auto_invoke_nvm; and test "$auto_invoke_nvm" = true
        nvm use 2>/tmp/_nvm_auto_invoke.log
    end
end
