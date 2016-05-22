function __fnm_usage
    set -l uline (set_color -u)
    set -l nc (set_color normal)

    echo "Usage: fnm [COMMAND] [VERSION]"
    echo
    echo "where COMMAND can be one of:"
    echo "       "$uline"u"$nc"se  Use the given node version (default)"
    echo "       "$uline"r"$nc"m   Remove the given node version/s"
    echo "       "$uline"l"$nc"s   List the available node version/s"
    echo
    echo "and VERSION one of:"
    echo "     X.X.X   Version number"
    echo "    latest   Latest stable node release"
    echo "       lts   Latest LTS node release"
end
