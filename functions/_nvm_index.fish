function _nvm_index
    set --local versions (string split \n <$nvm_data/.index)
    set --query versions[1] || return
    set --query nvm_alpha || set versions (string match --invert -- "*-alpha.*" $versions)
    set versions[1] (string split " " -- $versions[1])[1]" latest"
    string join \n -- $versions
end
