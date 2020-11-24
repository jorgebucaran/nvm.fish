complete -c nvm --exclusive --long help -d ""
complete -c nvm --exclusive --long version -d ""

complete -c nvm --exclusive --condition "__fish_use_subcommand" -a install -d ""
complete -c nvm --exclusive --condition "__fish_use_subcommand" -a use -d ""
complete -c nvm --exclusive --condition "__fish_use_subcommand" -a list -d ""
complete -c nvm --exclusive --condition "__fish_use_subcommand" -a list-remote -d ""
complete -c nvm --exclusive --condition "__fish_use_subcommand" -a remove -d ""
complete -c nvm --exclusive --condition "__fish_use_subcommand" -a current -d ""
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from install" -a "(string split ' ' <$nvm_data/.index)"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from remove" -a "(_nvm_list | string split ' ' | string replace system '')"
complete -c nvm --exclusive --condition "__fish_seen_subcommand_from use" -a "(_nvm_list | string split ' ')"

set -q nvm_default_version \
    && complete -c nvm --exclusive --condition "__fish_seen_subcommand_from use remove" -a default