source (status dirname)/../functions/_nvm_auto_invoke.fish

@test "auto invoke changes Node version when .nvmrc file exists with value" (
    echo "" > /tmp/_nvm_auto_invoke.log
    echo "invalid version" > .nvmrc

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = 'nvm: Node version not installed or invalid: ""'

@test "auto invoke ignored when .nvmrc file is missing" (
    echo "" > /tmp/_nvm_auto_invoke.log
    rm .nvmrc

    _nvm_auto_invoke

    cat /tmp/_nvm_auto_invoke.log
) = 'nvm: Invalid version or missing ".nvmrc" file'
