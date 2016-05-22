function __fnm_mirror
    if test -z "$fnm_mirror"
        printf "%s\n" "http://nodejs.org/dist"
    else
        printf "%s\n" "$fnm_mirror[1]"
    end
end
