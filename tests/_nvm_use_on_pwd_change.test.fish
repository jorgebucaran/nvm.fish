source (status dirname)/../functions/_nvm_use_on_pwd_change.fish

function clean_up
    echo "" >/tmp/_nvm_use_on_pwd_change.log
    rm --force .nvmrc
    set --erase --universal nvm_use_on_pwd_change
end

function activate_feature
    set --universal nvm_use_on_pwd_change true
end

@test "When feature-flag is set to default then auto-invoke is skipped" (
    clean_up
    set --erase --universal nvm_use_on_pwd_change

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = ''

@test "When feature-flag is enable then auto-invoke is called" (
    clean_up
    activate_feature

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = 'nvm: Invalid version or missing ".nvmrc" file'

@test "auto-invoke changes Node version when .nvmrc file exists with value" (
    clean_up
    activate_feature
    echo "invalid version" > .nvmrc

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = 'nvm: Node version not installed or invalid: ""'

@test "auto-invoke ignored when .nvmrc file is missing" (
    clean_up
    activate_feature

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = 'nvm: Invalid version or missing ".nvmrc" file'
