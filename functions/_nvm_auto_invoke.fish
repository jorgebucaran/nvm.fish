function _nvm_auto_invoke \
    --on-variable PWD \
    --description 'Use Node.js version specified by project automatically'
    nvm use 2>/tmp/_nvm_auto_invoke.log
end
