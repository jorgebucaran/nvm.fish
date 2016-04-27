function __fin_index_update
    set -l index "$fin_cache/index"
    set -l interval 4320

    if test ! -z "$fin_index_update_interval"
        set interval "$fin_index_update_interval"
    end

    if test -s "$index"
        if test (get_file_age "$index") -lt "$interval"
            return
        end
    end

    fish -c "curl -sS http://nodejs.org/dist/index.tab > '$index'" &

    await (last_job_id -l)

    if test ! -s "$index"
        return 1
    end

    command awk '

        /^v0\.[1-9]\.[0-9]+/ {
            next # only >= 0.10
        }

        //

    ' "$index" > "$index-copy"

    command mv -f "$index-copy" "$index"
end
