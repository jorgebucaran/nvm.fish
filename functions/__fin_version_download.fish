function __fin_version_download -a v target
    set -l os (uname -s)
    set -l file
    set -l mirror_url "$FIN_MIRROR"

    if test -z "$mirror_url"
        set mirror_url "http://nodejs.org/dist"
    end

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

    set -l url "$mirror_url/v$v/$file"

    echo "Downloading <$url>"

    command mkdir -p "$target"

    pushd "$target"

    if not curl --progress-bar -O "$url"
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
