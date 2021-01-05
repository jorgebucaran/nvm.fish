function _nvm_list
    set --local versions $nvm_data/*
    set --query versions[1] &&
        string match --entire --regex -- (string match --regex -- "v\d.+" $versions |
            string escape --style=regex |
            string join "|"
        ) <$nvm_data/.index

    command --all node |
        string match --quiet --invert --regex -- "^$nvm_data" && echo system
end
