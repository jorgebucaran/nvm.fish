source (status dirname)/../functions/_nvm_auto_invoke.fish

function clean_up
    echo "" >/tmp/_nvm_auto_invoke.log
    rm --force .nvmrc
    set --erase --universal auto_invoke_nvm
end

function activate_feature
    set --universal auto_invoke_nvm true
end

@test "When feature-flag is set to default then auto-invoke is skipped" (
    clean_up
    set --erase --universal auto_invoke_nvm

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = ''

@test "When feature-flag is enable then auto-invoke is called" (
    clean_up
    activate_feature

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = 'nvm: Invalid version or missing ".nvmrc" file'

@test "auto-invoke changes Node version when .nvmrc file exists with value" (
    clean_up
    activate_feature
    echo "invalid version" > .nvmrc

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = 'nvm: Node version not installed or invalid: ""'

@test "auto-invoke ignored when .nvmrc file is missing" (
    clean_up
    activate_feature

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = 'nvm: Invalid version or missing ".nvmrc" file'
