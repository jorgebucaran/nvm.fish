function _nvm_list
    set --local nodes $nvm_data/*

    if set --query nodes[1]
        string match --entire --regex (
            string match --regex "v\d.+" $nodes | string escape --style=regex | string join "|"
        ) <$nvm_data/.index
    end

    command --all node | string match --quiet --invert --regex "^$nvm_data" && echo system
end

