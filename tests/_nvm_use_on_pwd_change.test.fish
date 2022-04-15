source (status dirname)/../functions/_nvm_use_on_pwd_change.fish

function clean_up
    rm --force /tmp/_nvm_use_on_pwd_change.log
    rm --force .nvmrc
    set --erase --universal nvm_use_on_pwd_change
end

function activate_feature
    set --universal nvm_use_on_pwd_change true
end

@test "When feature-flag is set to default then autoload is not run so no log" (
    clean_up
    set --erase --universal nvm_use_on_pwd_change

    _nvm_use_on_pwd_change
) ! -e /tmp/_nvm_use_on_pwd_change.log

@test "When feature-flag is set to default then autoload is run so there is log" (
    clean_up
    activate_feature

    _nvm_use_on_pwd_change
) -e /tmp/_nvm_use_on_pwd_change.log

@test "when .nvmrc file exists with value then use version from .nvmrc" (
    clean_up
    activate_feature
    echo "invalid version" > .nvmrc

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = 'nvm: Can\'t use Node "invalid version", version must be installed first'

@test "when .nvmrc file is missing then ignored" (
    clean_up
    activate_feature

    _nvm_use_on_pwd_change

    cat /tmp/_nvm_use_on_pwd_change.log
) = 'nvm: Invalid version or missing ".nvmrc" file'
