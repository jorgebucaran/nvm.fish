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

    set -l c (set_color -o $fish_color_param)
    set -l nc (set_color normal)
    set -l hm_url "$mirror/$c"v"$v$nc/$file"

    echo "Downloading <$hm_url>"

    set -l url "$mirror/v$v/$file"

    command mkdir -p "$target"
    pushd "$target"

    if not curl --fail --progress-bar -SLO "$url"
        command rm -rf "$target"

        echo "fin: I could not fetch $file from:" > /dev/stderr
        echo "     <$url>" > /dev/stderr
        echo > /dev/stderr
        echo "Hint: This is most likely a problem with http://nodejs.org" > /dev/stderr
        echo "      or a connection timeout. If the the problem persists" > /dev/stderr
        echo "      visit: <github.com/fisherman/fin/issues>" > /dev/stderr

        return 1
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
