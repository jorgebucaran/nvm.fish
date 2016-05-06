function __fin_version_download -a v target
    set -l os (uname -s)
    set -l mirror (__fin_mirror)
    set -l file

    switch "$os"
        case Linux
            set -l arch (uname -m)

            if test "$arch" = "x86_64"
                set arch 64
            else
                set arch 86
            end

            set file "node-v$v-linux-x$arch.tar.gz"

        case Darwin
            set file "node-v$v-darwin-x64.tar.gz"

        case \*
            return 2
    end

    set -l url "$mirror/v$v/$file"

    echo "Downloading <$url>"

    command mkdir -p "$target"

    pushd "$target"

    if not curl --progress-bar -LO "$url"
        command rm -rf "$target"
    end

    fish -c "
        builtin cd '$target'
        command tar -zx --strip-components=1 < '$file'
        command rm -f '$file'
    " &

    await (last_job_id -l)

    popd

    if test ! -d "$target"
        return 1
    end
end
