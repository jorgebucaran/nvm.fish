function node -d "Server-side JavaScript runtime" -w node
    if test -e "node_modules/.bin/node"
        node_modules/.bin/node $argv
    else
        __fnm_run_bin_as "node" $argv
    end
end
