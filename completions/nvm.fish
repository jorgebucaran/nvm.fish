complete -c nvm --exclusive --long version -d "Print version"
complete -c nvm --exclusive --long help -d "Print this help message"

complete -c nvm --exclusive --condition __fish_use_subcommand -a install -d "Download and activate the specified Node version"
complete -c nvm --exclusive --condition __fish_use_subcommand -a use -d "Activate a version in the current shell"
complete -c nvm --exclusive --condition __fish_use_subcommand -a list -d "List installed versions"
complete -c nvm --exclusive --condition __fish_use_subcommand -a list-remote -d "List versions available to install matching optional regex"
complete -c nvm --exclusive --condition __fish_use_subcommand -a current -d "Print the currently-active version"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from install" -a "(
    test -e $nvm_data && string split ' ' <$nvm_data/.index
)"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from use" -a "(_nvm_list | string split ' ')"
complete -c nvm --exclusive --condition __fish_use_subcommand -a uninstall -d "Uninstall a version"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from uninstall" -a "(
    _nvm_list | string split ' ' | string replace system ''
)"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from use uninstall" -a "(
    set --query nvm_default_version && echo default
)"
