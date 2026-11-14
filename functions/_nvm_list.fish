function _nvm_list
    set --local versions $nvm_data/*

    set --query versions[1] && for line in (_nvm_index)
        test -d $nvm_data/(string split " " -- $line)[1] && echo $line
    end

    command --all node |
        string match --quiet --invert --regex -- "^$nvm_data" && echo system
end
