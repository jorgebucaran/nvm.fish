function _nvm_index_update
    test ! -d $nvm_data && command mkdir -p $nvm_data

    set --local index $nvm_data/.index

    if not command curl --location --silent $nvm_mirror/index.tab >$index.temp
        command rm -f $index.temp
        echo "nvm: Can't update index, host unavailable: \"$nvm_mirror\"" >&2
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
