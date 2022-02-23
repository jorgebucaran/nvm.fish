function _nvm_index_update --argument-names mirror index
    set --local index_dir (dirname $index)
    set --local index_dir_present (test -f $index_dir)

    if not test "$index_dir_present"
        mkdir -p $index_dir
    end

    if not command curl --location --silent $mirror/index.tab >$index.temp
        command rm -f $index.temp
        echo "nvm: Can't update index, host unvailable: \"$mirror\"" >&2
        return 1
    end

    command awk -v OFS=\t '
        /v0.9.12/ { exit } # Unsupported
        NR > 1 {
            print $1 (NR == 2  ? " latest" : $10 != "-" ? " lts/" tolower($10) : "")
        }
    ' $index.temp >$index

    command rm -f $index.temp
end
