if test ! -z "$fnm_config"
    if set -l i (contains --index -- "$fnm_config/bin" $PATH)
        set -e PATH[$i]
    end
end
