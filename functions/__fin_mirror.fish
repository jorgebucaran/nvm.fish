function __fin_mirror
    if test -z "$fin_mirror"
        printf "%s\n" "http://nodejs.org/dist"
    else
        printf "%s\n" "$fin_mirror[1]"
    end
end
