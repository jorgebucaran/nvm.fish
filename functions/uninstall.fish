if test ! -z "$fin_config"
    if set -l i (contains --index -- "$fin_config/bin" $PATH)
        set -e PATH[$i]
    end
end
