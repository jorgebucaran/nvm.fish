complete nvm --exclusive --long version --description "Print version"
complete nvm --exclusive --long help --description "Print help"

complete nvm --exclusive --condition __fish_use_subcommand --arguments install --description "Download and activate the specified Node version"
complete nvm --exclusive --condition __fish_use_subcommand --arguments use --description "Activate a version in the current shell"
complete nvm --exclusive --condition __fish_use_subcommand --arguments list --description "List installed versions"
complete nvm --exclusive --condition __fish_use_subcommand --arguments list-remote --description "List versions available to install matching optional regex"
complete nvm --exclusive --condition __fish_use_subcommand --arguments current --description "Print the currently-active version"
complete nvm --exclusive --condition "__fish_seen_subcommand_from install" --arguments "(
    test -e $nvm_data && string split ' ' <$nvm_data/.index
)"
complete nvm --exclusive --condition "__fish_seen_subcommand_from use" --arguments "(_nvm_list | string split ' ')"
complete nvm --exclusive --condition __fish_use_subcommand --arguments uninstall --description "Uninstall a version"
complete nvm --exclusive --condition "__fish_seen_subcommand_from uninstall" --arguments "(
    _nvm_list | string split ' ' | string replace system ''
)"
complete nvm --exclusive --condition "__fish_seen_subcommand_from use uninstall" --arguments "(
    set --query nvm_default_version && echo default
)"
