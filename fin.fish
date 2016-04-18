# The MIT License (MIT)
#
# Copyright (c) 2016 Jorge Bucaran
#
# Permission is hereby granted, free of charge,  to any person obtaining a copy of
# this software  and associated documentation  files (the "Software"), to  deal in
# the Software  without restriction,  including without  limitation the  rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to  whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright  notice and this permission notice shall  be included in all
# copies or substantial portions of the Software.
#
# THE  SOFTWARE IS  PROVIDED "AS  IS", WITHOUT  WARRANTY OF  ANY KIND,  EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR  PURPOSE AND NONINFRINGEMENT. IN NO EVENT  SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE  LIABLE FOR ANY CLAIM, DAMAGES OR  OTHER LIABILITY, WHETHER
# IN  AN ACTION  OF  CONTRACT, TORT  OR  OTHERWISE,  ARISING FROM,  OUT  OF OR  IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


function __fin_install
    if test -z "$argv"
        __fin_read_bundle_file | read -az argv
    end

    set -e __fin_fetch_plugins_state

    if set -l fetched (__fin_plugin_fetch_items (__fin_plugin_get_missing $argv))
        if test -z "$fetched"
            set -l count (count $argv)

            if test "$count" -eq 1
                if test -d "$argv[1]"
                    set argv[1] (__fin_plugin_normalize_path "$argv[1]")
                end

                set -l base (__fin_plugin_get_names "$argv[1]")[1]

                __fin_log warn "
                    It seems @$base@ is already installed
                    __""$fin_config/$base""__
                " $__fin_stderr

            else
                __fin_log warn "No plugins to install or missing dependencies." $__fin_stderr

                __fin_log says "

                    If you tried to install any plugins, it's likely
                    they are already installed in your shell. To see
                    what's installed, run @fin ls@.
                " $__fin_stderr
            end

            return 1
        end

        for i in $fetched
            __fin_plugin_enable "$fin_config/$i"
        end

    else
        __fin_log error "
            There was an error cloning @$fetched@.
        " $__fin_stderr

        __fin_log says "

            You can use a url or prepend a namespace to
            the plugin's name, for example: @omf@/$fetched
        " $__fin_stderr

        return 1
    end
end


function __fin_plugin_fetch_items
    __fin_show_spinner

    set -l jobs
    set -l links
    set -l white
    set -l count (count $argv)

    if test "$count" -eq 0
        return
    end

    switch "$__fin_fetch_plugins_state"
        case ""
            if test "$count" = 1 -a -d "$argv[1]"
                if test "$argv[1]" = "$PWD"
                    set -l home ~
                    set -l name (printf "%s\n" "$argv[1]" | sed "s|$home|~|")

                    __fin_log says "Installing __""$name""__ " $__fin_stderr
                else
                    set -l name (printf "%s\n" "$argv[1]" | sed "s|$PWD/||")

                    __fin_log says "Installing __""$name""__ " $__fin_stderr
                end
            else
                __fin_log says "Installing @$count@ plugin/s" $__fin_stderr
            end

            set -g __fin_fetch_plugins_state "fetching"

        case "fetching"
            __fin_log says "Installing @$count@ dependencies" $__fin_stderr
            set -g __fin_fetch_plugins_state "done"

        case "done"
    end

    for i in $argv
        set -l names

        switch "$i"
            case \*gist.github.com\*
                __fin_log says "Resolving gist name..."
                if not set names (__fin_get_plugin_name_from_gist "$i") ""
                    __fin_log error "
                        I couldn't find your gist
                        @$i@
                    "
                    continue
                end

            case \*
                set names (__fin_plugin_get_names "$i")
        end

        if test -d "$i"
            command ln -sfF "$i" "$fin_config/$names[1]"
            set links $links "$names[1]"
            continue
        end

        set -l source "$fin_cache/$names[1]"

        if test -z "$names[2]"
            if test -d "$source"
                if test -L "$source"
                    command ln -sfF "$source" "$fin_config"
                else
                    command cp -rf "$source" "$fin_config"
                end
            else
                set jobs $jobs (__fin_plugin_url_clone_async "$i" "$names[1]")
            end
        else
            if test -d "$source"
                set -l real_namespace (__fin_plugin_get_url_info --dirname "$source" )

                if test "$real_namespace" = "$names[2]"
                    command cp -rf "$source" "$fin_config"
                else
                    set jobs $jobs (__fin_plugin_url_clone_async "$i" "$names[1]")
                end
            else
                set jobs $jobs (__fin_plugin_url_clone_async "$i" "$names[1]")
            end
        end

        set fetched $fetched "$names[1]"
    end

    __fin_jobs_await $jobs

    for i in $fetched
        if test ! -d "$fin_cache/$i"
            printf "%s\n" "$i"
            return 1
        end
    end

    if test ! -z "$fetched"
        __fin_plugin_fetch_items (__fin_plugin_get_missing $fetched)
        printf "%s\n" $fetched
    end

    if test ! -z "$links"
        __fin_plugin_fetch_items (__fin_plugin_get_missing $links)
        printf "%s\n" $links
    end
end


function __fin_plugin_url_clone_async -a url name
    switch "$url"
        case https://\*
        case github.com/\*
            set url "https://$url"

        case \?\*/\?\*
            set url "https://github.com/$url"

        case \*
            set url "https://github.com/fisherman/$url"
    end

    set -l nc (set_color normal)
    set -l red (set_color red)
    set -l uline (set_color -u)
    set -l green (set_color green)
    set -l cyan (set_color cyan)

    set -l hm_url (printf "%s\n" "$url" | sed 's|^https://||')

    fish -c "
            set -lx GIT_ASKPASS /bin/echo

            if command git clone -q --depth 1 '$url' '$fin_cache/$name' ^ /dev/null
                  printf 'fin $green""OKAY""$nc $green✔$nc Fetched $cyan%s$nc %48s\n' '$name' '$uline$hm_url$nc'
                  command cp -rf '$fin_cache/$name' '$fin_config'
            else
                  printf 'fin $red""ARGH""$nc $red✘$nc Errror $cyan%s$nc %48s\n' '$name' '$uline$hm_url$nc'
            end
      " > /dev/stderr &

    __fin_jobs_get -l
end


function __fin_update
    set -l jobs
    set -l count (count $argv)
    set -l updated
    set -l skipped 0

    if test "$count" = 0
        return
    end

    if test "$count" -eq 1
        __fin_log says "Updating @$count@ plugin" $__fin_stderr
    else
        __fin_log says "Updating @$count@ plugins" $__fin_stderr
    end

    for i in $argv
        set -l path "$fin_config/$i"

        if test -d "$path"
            set updated $updated "$i"

            if test -L "$fin_config/$i"
                set skipped (math "$skipped + 1")
                continue
            end

            set jobs $jobs (__fin_update_path_async "$i" "$path")
        else
            __fin_log warn "@$i@ is not installed"
        end
    end

    __fin_jobs_await $jobs

    set -g __fin_fetch_plugins_state "fetching"
    set -l fetched (__fin_plugin_fetch_items (__fin_plugin_get_missing $updated))

    for i in $updated $fetched
        if test "$i" = "$fin_active_prompt"
            set fin_active_prompt
        end
        __fin_plugin_enable "$fin_config/$i"
    end

    if test "$skipped" -gt 0
        __fin_log warn "Skipped @$skipped@ symlinks" $__fin_stderr
    end
end


function __fin_self_update
    set -l raw_url "https://raw.githubusercontent.com/fisherman/fin/master/fin.fish"
    set -l fake_qs (date "+%s")
    set -l file (status --current-filename)

    set -l previous_version "$fin_version"

    fish -c "curl --max-time 5 -sS '$raw_url?$fake_qs' > $file.$fake_qs" &

    __fin_jobs_await (__fin_jobs_get -l)

    if test -s "$file.$fake_qs"
        command mv "$file.$fake_qs" "$file"
    end

    source "$file"
    fin -v > /dev/null
    set -l new_version "$fin_version"

    if test "$previous_version" = "$fin_version"
        __fin_log says "@fin is up to date@" $__fin_stderr
    else
        __fin_log okay "You are now running fin @$fin_version@" $__fin_stderr

        __fin_log says "

            To see the change log, please visit:
            __https://github.com/fisherman/fin/releases
        " $__fin_stderr
    end
end


function __fin_update_path_async -a name path
    set -l nc (set_color normal)
    set -l red (set_color red)
    set -l uline (set_color -u)
    set -l green (set_color green)
    set -l cyan (set_color cyan)

    fish -c "

        pushd $path

        if not command git fetch -q origin master ^ /dev/null
            printf 'fin $red""ARGH""$nc $red✘$nc Errror $cyan%s$nc\n' '$name'
            exit
        end

        set -l commits (command git rev-list --left-right --count master..FETCH_HEAD ^ /dev/null | cut -d\t -f2)

        command git reset -q --hard FETCH_HEAD ^ /dev/null
        command git clean -qdfx

        if test -z \"\$commits\" -o \"\$commits\" -eq 0
            printf 'fin $green""OKAY""$nc $green•$nc Latest $cyan%s$nc\n' '$name'
            command cp -rf '$path' '$fin_cache/$name'
        else
            printf 'fin $green""OKAY""$nc $green▸$nc $cyan%s$nc new commits $cyan%s$nc\n' \$commits '$name'
        end

    " > /dev/stderr &

    __fin_jobs_get -l
end


function __fin_plugin_enable -a path
    if __fin_plugin_is_prompt "$path"
        if test ! -z "$fin_active_prompt"
            __fin_plugin_disable "$fin_config/$fin_active_prompt"
        end

        set -U fin_active_prompt (basename "$path")
    end

    set -l plugin_name (basename $path)

    for file in $path/{functions/*,}*.fish
        set -l base (basename "$file")

        if test "$base" = "uninstall.fish"
            continue
        end

        switch "$base"
            case {,fish_}key_bindings.fish
                __fin_key_bindings_append "$plugin_name" "$file"
                continue
        end

        set -l dir "functions"

        if test "$base" = "init.fish"
            set dir "conf.d"

            set base "$plugin_name.$base"
        end

        set -l target "$fish_config/$dir/$base"

        command ln -sfF "$file" "$target"
        builtin source "$target"

        if test "$base" = "set_color_custom.fish"
            printf "%s\n" "$fish_color_normal" "$fish_color_command" "$fish_color_param" "$fish_color_redirection" "$fish_color_comment" "$fish_color_error" "$fish_color_escape" "$fish_color_operator" "$fish_color_end" "$fish_color_quote" "$fish_color_autosuggestion" "$fish_color_user" "$fish_color_valid_path" "$fish_color_cwd" "$fish_color_cwd_root" "$fish_color_match" "$fish_color_search_match" "$fish_color_selection" "$fish_pager_color_prefix" "$fish_pager_color_completion" "$fish_pager_color_description" "$fish_pager_color_progress" "$fish_color_history_current" "$fish_color_host" > "$fish_config/fish_colors"
            set_color_custom
        end
    end

    for file in $path/conf.d/*.{py,awk}
        set -l base (basename "$file")
        command ln -sfF "$file" "$fish_config/conf.d/$base"
    end

    for file in $path/{functions/,}*.{py,awk}
        set -l base (basename "$file")
        command ln -sfF "$file" "$fish_config/functions/$base"
    end

    for file in $path/conf.d/*.fish
        set -l base (basename "$file")
        set -l target "$fish_config/conf.d/$base"

        command ln -sfF "$file" "$target"
        builtin source "$target"
    end

    for file in $path/completions/*.fish
        set -l base (basename "$file")
        set -l target "$fish_config/completions/$base"

        command ln -sfF "$file" "$target"
        builtin source "$target"
    end

    return 0
end


function __fin_plugin_disable -a path
    set -l plugin_name (basename $path)

    for file in $path/{functions/*,}*.fish
        set -l name (basename "$file" .fish)
        set -l base "$name.fish"

        if test "$base" = "uninstall.fish"
            builtin source "$file"
            continue
        end

        switch "$base"
            case {,fish_}key_bindings.fish
                __fin_key_bindings_remove "$plugin_name"
                continue
        end

        set -l dir "functions"

        if test "$base" = "init.fish"
            set dir "conf.d"
            set base "$plugin_name.$base"
        end

        command rm -f "$fish_config/$dir/$base"

        functions -e "$name"

        if test "$base" = "set_color_custom.fish"
            set -l fish_colors_config "$fish_config/fish_colors"

            if test ! -f "$fish_colors_config"
                __fin_reset_default_fish_colors
                continue
            end

            set -l IFS \n

            read -laz colors < $fish_colors_config
            set colors[25] ""

            set -l IFS " "

            echo "$colors[1]" | read -a -U fish_color_normal
            echo "$colors[2]" | read -a -U fish_color_command
            echo "$colors[3]" | read -a -U fish_color_param
            echo "$colors[4]" | read -a -U fish_color_redirection
            echo "$colors[5]" | read -a -U fish_color_comment
            echo "$colors[6]" | read -a -U fish_color_error
            echo "$colors[7]" | read -a -U fish_color_escape
            echo "$colors[8]" | read -a -U fish_color_operator
            echo "$colors[9]" | read -a -U fish_color_end
            echo "$colors[10]" | read -a -U fish_color_quote
            echo "$colors[11]" | read -a -U fish_color_autosuggestion
            echo "$colors[12]" | read -a -U fish_color_user
            echo "$colors[13]" | read -a -U fish_color_valid_path
            echo "$colors[14]" | read -a -U fish_color_cwd
            echo "$colors[15]" | read -a -U fish_color_cwd_root
            echo "$colors[16]" | read -a -U fish_color_match
            echo "$colors[17]" | read -a -U fish_color_search_match
            echo "$colors[18]" | read -a -U fish_color_selection
            echo "$colors[19]" | read -a -U fish_pager_color_prefix
            echo "$colors[20]" | read -a -U fish_pager_color_completion
            echo "$colors[21]" | read -a -U fish_pager_color_description
            echo "$colors[22]" | read -a -U fish_pager_color_progress
            echo "$colors[23]" | read -a -U fish_color_history_current
            echo "$colors[24]" | read -a -U fish_color_host

            command rm -f $fish_colors_config
        end
    end

    for file in $path/conf.d/*.{py,awk}
        set -l base (basename "$file")
        command rm -f "$fish_config/conf.d/$base"
    end

    for file in $path/{functions/,}*.{py,awk}
        set -l base (basename "$file")
        command rm -f "$fish_config/functions/$base"
    end

    for file in $path/conf.d/*.fish
        set -l base (basename "$file")
        command rm -f "$fish_config/conf.d/$base"
    end

    for file in $path/completions/*.fish
        set -l name (basename "$file" .fish)
        set -l base "$name.fish"

        command rm -f "$fish_config/completions/$base"
        complete -c "$name" --erase
    end

    if __fin_plugin_is_prompt "$path"
        set -U fin_active_prompt
        builtin source $__fish_datadir/functions/fish_prompt.fish ^ /dev/null
    end

    command rm -rf "$path" > /dev/stderr
end


function __fin_get_plugin_name_from_gist -a url
    set -l gist_id (printf "%s\n" "$url" | command sed 's|.*/||')
    set -l name (fish -c "

        fin -v > /dev/null
        curl -Ss https://api.github.com/gists/$gist_id &

        __fin_jobs_await (__fin_jobs_get -l)

    " | command awk '

        /"files": / {
            files++
        }

        /"[^ ]+.fish": / && files {
            gsub("^ *\"|\.fish.*", "")
            print
        }

    ')

    if test -z "$name"
        return 1
    end

    printf "%s\n" $name
end


function __fin_list
    set -l config $fin_config/*

    if test -z "$config"
        return 1
    end

    set -l white
    set -l links (command find $config -maxdepth 0 -type l ! -name "$fin_active_prompt" ^ /dev/null)
    set -l names (command find $config -maxdepth 0 -type d ! -name "$fin_active_prompt" ^ /dev/null)

    if test ! -z "$links"
        set white "  "
        printf "%s\n" $links | command sed "s|.*/|@ |"
    end

    if test ! -z "$fin_active_prompt"
        set white "  "
        printf "* %s\n" "$fin_active_prompt"
    end

    if test ! -z "$names"
        printf "%s\n" $names | command sed "s|.*/|$white|"
    end
end


function __fin_list_plugin_directory -a item
    set -l fd $__fin_stderr

    set -e argv[1]
    set -l path "$fin_config/$item"

    if test ! -d "$path"
        __fin_log error "$item is not installed" $__fin_stderr

        return 1
    end

    pushd "$path"

    set -l color (set_color $fish_color_command)
    set -l nc (set_color normal)
    set -l inside_tree

    if contains -- --no-color $argv
        set color
        set nc
        set fd $__fin_stdout
    end

    printf "$color%s$nc\n" "$PWD" > $fd

    for file in .* **
        if test -f "$file"
            switch "$file"
                case .\*
                    printf "    %s\n" $file
                    set inside_tree

                case \*/\*
                    if test -z "$inside_tree"
                        printf "    $color%s/$nc\n" (dirname $file)
                        set inside_tree -
                    end
                    printf "        %s\n" (basename $file)

                case \*
                    printf "    %s\n" $file
                    set inside_tree
            end
        end
    end > $fd

    popd
end


function __fin_log -a log message fd
    set -l nc (set_color normal)
    set -l red (set_color red)
    set -l warn (set_color black -b yellow)
    set -l green (set_color green)
    set -l bold (set_color cyan)
    set -l uline (set_color -u)

    switch "$fd"
        case "/dev/null"
            return

        case "" "/dev/stderr"
            set fd "/dev/stderr"

        case \*
            set nc ""
            set red ""
            set warn ""
            set green ""
            set bold ""
            set uline
    end

    printf "%s\n" "$message" | command awk '
        function okay(name, s) {
            printf("'$nc'%s '$green'%s'$nc' %s\n", name, "OKAY", s)
        }

        function says(name, s) {
            printf("'$nc'%s '$green'%s'$nc' %s\n", name, "SAYS", s)
        }

        function warn(name, s) {
            printf("'$nc'%s '$warn'%s'$nc' %s\n", name, "WARN", s)
        }

        function error(name, s) {
            printf("'$nc'%s '$red'%s'$nc' %s\n", name, "ARGH", s)
        }

        {
            sub(/^[ ]+/, "")
            gsub("``", "  ")

            if (/@[^@]+@/) {
                n = match($0, /@[^@]+@/)
                if (n) {
                    sub(/@[^@]+@/, "'$bold'" substr($0, RSTART + 1, RLENGTH - 2) "'$nc'", $0)
                }
            }

            if (/__[^_]+__/) {
                n = match($0, /__[^_]+__/)
                if (n) {
                    sub(/__[^_]+__/, "'$uline'" substr($0, RSTART + 2, RLENGTH - 4) "'$nc'", $0)
                }
            }

            s[++len] = $0
        }

        END {
            for (i = 1; i <= len; i++) {
                if ((i == 1 || i == len) && (s[i] == "")) {
                    continue
                }

                if (s[i] == "") {
                    print
                } else {
                    '$log'("fin", s[i])
                }
            }
        }

    ' > "$fd"
end


function __fin_log_error_footer -a fd
    set -l url "https://github.com/fisherman/fin/issues"
    set -l debug_log "$fin_cache/fin-debug.log"

    __fin_log error "
            For more help, visit the issue tracker
            @$url@
            ``
            Include the following file with your issue
            @$debug_log@
      " $fd
end


function __fin_jobs_get
    jobs $argv | command awk -v FS=\t '
        /[0-9]+\t/{
            jobs[++job_count] = $1
        }

        END {
            for (i = 1; i <= job_count; i++) {
                print(jobs[i])
            }

            exit job_count == 0
        }
    '
end


function __fin_jobs_await
    if test -z "$argv"
        return
    end

    while true
        for spinner in $fin_spinners
            printf "  $spinner  \r" > /dev/stderr
            sleep 0.04
        end

        set -l currently_active_jobs (__fin_jobs_get)

        if test -z "$currently_active_jobs"
            break
        end

        set -l has_jobs

        for i in $argv
            if builtin contains -- $i $currently_active_jobs
                set has_jobs "*"
                break
            end
        end

        if test -z "$has_jobs"
            break
        end
    end
end


function __fin_key_bindings_remove -a plugin_name
    set -l user_key_bindings "$fish_config/functions/fish_user_key_bindings.fish"
    set -l tmp (date "+%s")

    fish_indent < "$user_key_bindings" | sed -n "/### $plugin_name ###/,/### $plugin_name ###/{s/^ *bind /bind -e /p;};" | source ^ /dev/null

    sed "/### $plugin_name ###/,/### $plugin_name ###/d" < "$user_key_bindings" > "$user_key_bindings.$tmp"
    command mv -f "$user_key_bindings.$tmp" "$user_key_bindings"

    if awk '
        /^$/ { next }

        /^function fish_user_key_bindings/ {
            i++
            next
        }

        /^end$/ && 1 == i {
            exit 0
        }

        // {
            exit 1
        }

    ' < "$user_key_bindings"

        command rm -f "$user_key_bindings"
    end
end


function __fin_key_bindings_append -a plugin_name file
    set -l user_key_bindings "$fish_config/functions/fish_user_key_bindings.fish"

    command mkdir -p (dirname "$user_key_bindings")
    touch "$user_key_bindings"

    set -l key_bindings_source (
        fish_indent < "$user_key_bindings" | awk '

            /^function fish_user_key_bindings/ {
                reading_function_source = 1
                next
            }

            /^end$/ {
                exit
            }

            reading_function_source {
                print $0
                next
            }

        '
    )

    set -l plugin_key_bindings_source (
        fish_indent < "$file" | awk -v name="$plugin_name" '

            BEGIN {
                printf("### %s ###\n", name)
            }

            END {
                printf("### %s ###\n", name)
            }

            /^function fish_user_key_bindings$/ {
                check_for_and_keyword = 1
                next
            }

            /^end$/ && check_for_and_keyword {
                end = 0
                next
            }

            !/^ *(#.*)*$/ {
                gsub("#.*", "")
                printf("%s\n", $0)
            }

        '
    )

    printf "%s\n" $key_bindings_source $plugin_key_bindings_source | awk '

        BEGIN {
            print "function fish_user_key_bindings"
        }

        //

        END {
            print "end"
        }

    ' | fish_indent > "$user_key_bindings"
end


function __fin_plugin_is_prompt -a path
    if test -e $path/fish_prompt.fish
        return
    end

    if test -e $path/functions/fish_prompt.fish
        return
    end

    if test -e $path/fish_right_prompt.fish
        return
    end

    if test -e $path/functions/fish_right_prompt.fish
        return
    end

    return 1
end


function __fin_plugin_get_names
    printf "%s\n" $argv | command awk '

        {
            sub(/\/$/, "")
            n = split($0, s, "/")
            sub(/^(omf|omf-theme|omf-plugin|plugin|theme|fish|fisher)-/, "", s[n])

            printf("%s\n%s\n", s[n], s[n - 1])
        }

    '
end


function __fin_plugin_get_url_info -a option
    set -e argv[1]

    if test -z "$argv"
        return
    end

    cat {$argv}/.git/config ^ /dev/null | command awk -v option="$option" '
        /url/ {
            n = split($3, s, "/")

            if ($3 ~ /https:\/\/gist/) {
                printf("# %s\n", $3)
                next
            }

            if (option == "--dirname") {
                printf("%s\n", s[n - 1])

            } else if (option == "--basename") {
                printf("%s\n", s[n])

            } else {
                printf("%s/%s\n", s[n - 1], s[n])
            }
        }
    '
end


function __fin_plugin_normalize_path
    printf "%s\n" $argv | command awk -v pwd="$PWD" '

        /^\.$/ {
            print(pwd)
            next
        }

        /^\// {
            sub(/\/$/, "")
            print($0)
            next
        }

        {
            print(pwd "/" $0)
            next
        }

    '
end


function __fin_plugin_get_missing
    for i in $argv
        if test -d "$i"
            set i (__fin_plugin_normalize_path "$i")
        end

        set -l name (__fin_plugin_get_names "$i")[1]

        if set -l path (__fin_plugin_is_installed "$name")
            for file in fishfile bundle
                if test -s "$path/$file"
                    __fin_plugin_get_missing (__fin_read_bundle_file < "$path/$file")
                end
            end
        else
            printf "%s\n" "$i"
        end
    end

    __fin_show_spinner
end


function __fin_plugin_is_installed -a name
    if test -z "$name" -o ! -d "$fin_config/$name"
        return 1
    end

    printf "%s\n" "$fin_config/$name"
end


function __fin_reset_default_fish_colors
    set -U fish_color_normal normal
    set -U fish_color_command 005fd7 purple
    set -U fish_color_param 00afff cyan
    set -U fish_color_redirection 005fd7
    set -U fish_color_comment 600
    set -U fish_color_error red --bold
    set -U fish_color_escape cyan
    set -U fish_color_operator cyan
    set -U fish_color_end green
    set -U fish_color_quote brown
    set -U fish_color_autosuggestion 555 yellow
    set -U fish_color_user green
    set -U fish_color_valid_path --underline
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_match cyan
    set -U fish_color_search_match --background=purple
    set -U fish_color_selection --background=purple
    set -U fish_pager_color_prefix cyan
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description 555 yellow
    set -U fish_pager_color_progress cyan
    set -U fish_color_history_current cyan
    set -U fish_color_host normal
end


function __fin_read_bundle_file
    command awk -v FS=\t '
        /^$/ || /^[ \t]*#/ {
            next
        }

        /^[ \t]*package / {
            sub("^[ \t]*package ", "oh-my-fish/plugin-")
        }

        {
            sub("^[@* \t]*", "")

            if (!seen[$0]++) {
                printf("%s\n", $0)
            }
        }
    '
end


function __fin_completions_write
    functions __fin_completions_write | fish_indent | __fin_parse_comments_from_function

    # complete -xc fin -s h -l help -d "Show usage help"
    # complete -xc fin -s q -l quiet -d "Enable quiet mode"
    # complete -xc fin -s v -l version -d "Show version information"
    # complete -xc fin -n "__fish_use_subcommand" -a install -d "Install plugins  /  i"
    # complete -xc fin -n "__fish_use_subcommand" -a update -d "Update fin and plugins  /  u"
    # complete -xc fin -n "__fish_use_subcommand" -a rm -d "Remove plugins  /  r"
    # complete -xc fin -n "__fish_use_subcommand" -a ls -d "List plugins  /  l"
    # complete -xc fin -n "__fish_use_subcommand" -a help -d "Show help  /  h"
end


function __fin_humanize_duration
    awk '
        function hmTime(time,   stamp) {
            split("h:m:s:ms", units, ":")

            for (i = 2; i >= -1; i--) {
                if (t = int( i < 0 ? time % 1000 : time / (60 ^ i * 1000) % 60 )) {
                    stamp = stamp t units[sqrt((i - 2) ^ 2) + 1] " "
                }
            }

            if (stamp ~ /^ *$/) {
                return "0ms"
            }

            return substr(stamp, 1, length(stamp) - 1)
        }

        {
            print hmTime($0)
        }
    '
end


function __fin_get_key
    stty -icanon -echo ^ /dev/null

    printf "$argv" > /dev/stderr

    while true
        dd bs=1 count=1 ^ /dev/null | read -p "" -l yn

        switch "$yn"
            case y Y n N
                printf "\n" > /dev/stderr
                printf "%s\n" $yn > /dev/stdout
                break
        end
    end

    stty icanon echo > /dev/stderr ^ /dev/null
end


function __fin_get_epoch_in_ms -a elapsed
    if test -z "$elapsed"
        set elapsed 0
    end

    perl -MTime::HiRes -e 'printf("%.0f\n", (Time::HiRes::time() * 1000) - '$elapsed')'
end


function __fin_parse_column_output
    command awk -v FS=\t '
        {

            for (i = 1; i <= NF; i++) {
                if ($i != "") {
                    print $i
                }
            }

        }
    '
end


function __fin_parse_comments_from_function
    command awk '

        /^[\t ]*# ?/ {
            sub(/^[\t ]*# ?/, "")
            a[++n] = $0
        }

        END {
            for (i = 1; i <= n; i++) {
                printf("%s\n", a[i])
            }
        }

    '
end


function __fin_usage
    set -l u (set_color -u)
    set -l nc (set_color normal)

    echo "Usage: fin [<command>] [<plugins>] [--quiet] [--version]"
    echo
    echo "where <command> can be one of:"
    echo "       "$u"i"$nc"nstall (default)"
    echo "       "$u"u"$nc"pdate"
    echo "       "$u"r"$nc"m"
    echo "       "$u"l"$nc"s"
    echo "       "$u"h"$nc"elp"
end


function __fin_help -a command number
    if test -z "$argv"
        set -l page "$fin_cache/fin.1"

        if test ! -s "$page"
            __fin_man_page_write > "$page"
        end

        set -l pager "/usr/bin/less -s"

        if test ! -z "$PAGER"
            set pager "$PAGER"
        end

        man -P "$pager" -- "$page"

        command rm -f "$page"

    else
        if test -z "$number"
            set number 1
        end

        set -l page "$fin_config/$command/man/man$number/$command.$number"

        if not man "$page" ^ /dev/null
            __fin_log error "No manual entry for $command" $__fin_stderr

            if test -d "$fin_config/$command"
                set -l url (__fin_plugin_get_url_info -- $fin_config/$command)

                if test ! -z "$url"
                    __fin_log says "Visit the online repository for help:" $__fin_stderr
                    __fin_log says "__https://github.com/$url" $__fin_stderr
                end
            else
                __fin_log error "$command is not installed" $__fin_stderr
            end

            return 1
        end
    end
end


function __fin_man_page_write
    functions __fin_man_page_write | fish_indent | __fin_parse_comments_from_function

    # .
    # .TH "FIN" "1" "April 2016" "" "fin"
    # .
    # .SH "NAME"
    # \fBfin\fR \- fish plugin manager
    # .
    # .SH "SYNOPSIS"
    # fin [\fIcommand\fR] [\fIplugins\fR] [\-\-quiet] [\-\-version]
    # .
    # .br
    # .
    # .SH "DESCRIPTION"
    # fin is a one\-file, no\-configuration, concurrent plugin manager for the fish shell\.
    # .
    # .SH "USAGE"
    # Install a plugin\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin superman
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Install from multiple sources\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin omf/{grc,thefuck} fzf z
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Install from a URL\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin https://github\.com/edc/bass
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Install from a gist\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin https://gist\.github\.com/username/1f40e1c6e0551b2666b2
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Install from a local directory\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin ~/my_aliases
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Use it a la vundle\. Edit \fB~/\.config/fish/bundle\fR and run \fBfin\fR to satisfy the changes\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # $EDITOR ~/\.config/fish/bundle # add plugins
    # fin
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # See what\'s installed\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin ls
    # @ my_aliases      # this plugin is a local directory
    # * superman        # this plugin is the current prompt
    #   bass
    #   fzf
    #   grc
    #   thefuck
    #   z
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Update everything\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin up
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Update some plugins\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin up bass z fzf thefuck
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Remove plugins\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin rm superman
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Remove everything\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin ls | fin rm
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # Get help\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin help z
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .SH "FAQ"
    # .
    # .SS "1\. How do I uninstall fin?"
    # Run
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin self\-destroy
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .SS "2\. What fish version is required?"
    # fin was built for the latest fish, but at least 2\.2\.0 is required\. If you can\'t upgrade your build, append the following code to your \fB~/\.config/fish/config\.fish\fR for snippet \fIhttps://github\.com/fisherman/fin/blob/master/faq\.md#12\-what\-is\-a\-plugin\fR support\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # for file in ~/\.config/fish/conf\.d/*\.fish
    #     source $file
    # end
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .SS "3\. Is fin compatible with fisherman and oh my fish themes and plugins?"
    # Yes\.
    # .
    # .SS "4\. Why fin? Why not ____?"
    # fin learns from my mistakes building oh my fish, wahoo and fisherman\. It also takes some ideas from fundle and chips\.
    # .
    # .P
    # Other reasons:
    # .
    # .IP "\(bu" 4
    # fast and easy to install, update and uninstall
    # .
    # .IP "\(bu" 4
    # small and fits in one file
    # .
    # .IP "\(bu" 4
    # you don\'t need to modify your fish configuration to use it
    # .
    # .IP "\(bu" 4
    # framework agnostic, no favorites
    # .
    # .IP "\(bu" 4
    # zero impact on shell startup time
    # .
    # .IP "" 0
    # .
    # .SS "5\. Where does fin put stuff?"
    # fin usually goes in \fB~/\.config/fish/functions/fin\.fish\fR\.
    # .
    # .P
    # The cache and plugin configuration is created in \fB~/\.cache/fin\fR and \fB~/\.config/fin\fR respectively\.
    # .
    # .P
    # The \fBbundle\fR file is stored in \fB~/\.config/fish\fR\.
    # .
    # .SS "6\. What is a bundle file and how do I use it?"
    # The bundle file lists all the installed plugins\.
    # .
    # .P
    # You can let fin take care of the bundle for you automatically, or write in the plugins you want and run \fBfin\fR to satisfy the changes\.
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fisherman/superman
    # omf/grc
    # omf/thefuck
    # fisherman/z
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .P
    # This mechanism only installs plugins and missing dependencies\. To remove a plugin, use \fBfin rm\fR instead\.
    # .
    # .P
    # The bundle file is inside your fish configuration directory \fB~/\.config/fish\fR so you can commit the entire tree to your dotfiles or only the bundle and that\'s it\.
    # .
    # .SS "7\. Where can I find a list of fish plugins?"
    # Browse github/fisherman, github/oh\-my\-fish, github/awesome\-fish or use the http://fisherman.sh online search to discover content\.
    # .
    # .SS "8\. How do I install, update, list or remove plugins?"
    # See \fIUsage\fR\.
    # .
    # .SS "9\. How do I upgrade from ___?"
    # You don\'t have to\. fin is framework agnostic and does not interfere with other known systems\. If you want to uninstall oh my fish or fisherman, refer to their documentation\.
    # .
    # .SS "10\. How do I update fin to the latest version?"
    # Run
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # fin up
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .SS "12\. What is a plugin?"
    # A plugin is:
    # .
    # .IP "1." 4
    # a directory or git repo with a function \fB\.fish\fR file either at the root level of the project or inside a \fBfunctions\fR directory
    # .
    # .IP "2." 4
    # a theme or prompt, i\.e, a \fBfish_prompt\.fish\fR, \fBfish_right_prompt\.fish\fR or both files
    # .
    # .IP "3." 4
    # a snippet, i\.e, one or more \fB\.fish\fR files inside a directory named \fBconf\.d\fR that are evaluated by fish at the start of the shell
    # .
    # .IP "" 0
    # .
    # .SS "13\. How can I list plugins as dependencies to my plugin?"
    # Create a new \fBbundle\fR file at the root level of your project and write in the plugin dependencies:
    # .
    # .IP "" 4
    # .
    # .nf
    #
    # owner/repo
    # https://github\.com/dude/sweet
    # https://gist\.github\.com/bucaran/c256586044fea832e62f02bc6f6daf32
    # .
    # .fi
    # .
    # .IP "" 0
    # .
    # .SS "14\. I have a question or request not addressed here\. Where should I put it?"
    # Create a new ticket on the issue tracker:
    # .
    # .IP "\(bu" 4
    # https://github\.com/fisherman/fin/issues
    # .
    # .IP "" 0
    # .
    # .SS "15\. Why did you create a new project instead of improving fisherman?"
    # .
    # .IP "1." 4
    # fisherman uses an index file and has built\-in search capabilities / advanced completions that are not compatible with fin\'s simpler model
    # .
    # .IP "2." 4
    # I wanted a clean slate and a chance to experiment with something different
    # .
    # .IP "3." 4
    # fin is more opinionated and pragmatic than fisherman, thus truer to fish configurability principle
    # .
    # .IP "" 0
    # .
    # .SS "16\. What about chips and fundle?"
    # chips is far from ready and it\'s not written in fish either\. fundle inspired me to use a bundle and one\-file distribution, but it has limited capabilities and still requires you to edit your fish configuration\.
    # .
    # .SS "17\. Does this mean you are done with fisherman?"
    # Nope\.
    # .
    # .SH "BUGS"
    # When you find issues, please report them:
    # .
    # .IP "\(bu" 4
    # \fIhttp://github\.com/fisherman/fin/issues\fR
    # .
    # .IP "" 0
    # .
    # .P
    # Be sure to include all of the output from fin that didn\'t work as expected\.
    # .
    # .SH "AUTHOR"
    # Fisherman was created by Jorge Bucaran :: @bucaran :: j@bucaran\.me
    # .
    # .P
    # See the contributor graph for a list of other people who have contributed to this project:
    # .
    # .IP "\(bu" 4
    # \fIhttps://github\.com/fisherman/fin/graphs/contributors\fR
    # .
    # .IP "" 0
end


function __fin_self_destroy
    if test -z "$fish_config" -o -z "$fin_cache" -o -z "$fin_config" -o -L "$fin_cache" -o -L "$fin_config"
        __fin_log error "

            Some of fin variables refer to symbolic links or were undefined.

            If you are running a custom fin setup, remove the following
            directories and files by yourself:

            @$fin_cache@
            @$fin_config@
            @$fish_config/functions/fin.fish@
            @$fish_config/completions/fin.fish@

        " /dev/stderr

        __fin_log_error_footer /dev/stderr

        return 1
    end

    set -l u (set_color -u)
    set -l nc (set_color normal)

    switch "$argv"
        case -y --yes
        case \*
            __fin_log warn "
                This will permanently remove fin from your system.
                The following directories and files will be erased:

                @$fin_cache@
                @$fin_config@
                @$fish_config/functions/fin.fish@
                @$fish_config/completions/fin.fish@

            " /dev/stderr

            echo -sn "Do you wish to continue? [Y/n] " > /dev/stderr

            __fin_get_key | read -l yn

            switch "$yn"
                case n N
                    set -l username

                    if test ! -z "$USER"
                        set username " $USER"
                    end

                    __fin_log okay "As you wish cap!"
                    return 1
            end
    end

    complete -c fin --erase

    __fin_show_spinner

    fin ls | fin rm

    __fin_show_spinner

    command rm -rf "$fin_cache" "$fin_config"
    command rm -f "$fish_config/functions/fin.fish" "$fish_config/completions/fin.fish"

    __fin_show_spinner

    set -e fin_active_prompt
    set -e fin_cache
    set -e fin_config
    set -e fish_config
    set -e fin_bundle
    set -e fin_version
    set -e fin_spinners

    for func in __fin_jobs_await __fin_plugin_url_clone_async __fin_completions_write __fin_plugin_fetch_items __fin_get_epoch_in_ms __fin_jobs_get __fin_get_key __fin_get_plugin_name_from_gist __fin_plugin_get_names __fin_plugin_get_url_info __fin_plugin_get_missing __fin_help __fin_humanize_duration __fin_install __fin_list __fin_list_plugin_directory __fin_log_error_footer __fin_man_page_write __fin_plugin_normalize_path __fin_parse_column_output __fin_parse_comments_from_function __fin_plugin_is_prompt __fin_plugin_disable __fin_plugin_enable __fin_plugin_is_installed __fin_read_bundle_file __fin_reset_default_fish_colors __fin_self_destroy __fin_self_update __fin_usage __fin_update __fin_update_path_async
        __fin_show_spinner
        functions -e "$func"
    end

    __fin_show_spinner

    functions -e __fin_show_spinner

    __fin_log says "

        Thanks for trying out fin. If you have a moment,
        please share your feedback in our issue tracker.

        @https://github.com/fisherman/fin/issues@

    " $__fin_stderr

    functions -e __fin_log
end


function fin
    set -g fin_version "1.0.0"
    set -g fin_spinners ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏

    function __fin_show_spinner
        if not set -q __fin_fg_spinner[1]
            set -g __fin_fg_spinner $fin_spinners
        end

        printf "  $__fin_fg_spinner[1]\r" > /dev/stderr

        set -e __fin_fg_spinner[1]
    end

    set -l config_home $XDG_CONFIG_HOME
    set -l cache_home $XDG_CACHE_HOME

    if test -z "$config_home"
        set config_home ~/.config
    end

    if test -z "$cache_home"
        set cache_home ~/.cache
    end

    if test -z "$fish_config"
        set -g fish_config "$config_home/fish"
    end

    if test -z "$fin_config"
        set -g fin_config "$config_home/fin"
    end

    if test -z "$fin_cache"
        set -g fin_cache "$cache_home/fin"
    end

    if test -z "$fin_bundle"
        set -g fin_bundle "$fish_config/bundle"
    end

    if not command mkdir -p "$fish_config/"{conf.d,functions,completions} "$fin_config" "$fin_cache"
        __fin_log error "
            I couldn't create the fin configuration.
            You need write permissions in these directories:

            @$fish_config@
            @$fin_config@
            @$fin_cache@
        " > /dev/stderr

        return 1
    end

    set -l elapsed (__fin_get_epoch_in_ms)

    set -g __fin_stdout /dev/stdout
    set -g __fin_stderr /dev/stderr

    set -l command

    for flag in -q --quiet
        if set -l index (builtin contains --index -- $flag $argv)
            set -e argv[$index]
            set __fin_stdout /dev/null
            set __fin_stderr /dev/null

            break
        end
    end

    switch "$argv[1]"
        case i install
            set -e argv[1]
            set command "install"

        case u up update
            set -e argv[1]
            set command "update"

        case r rm remove uninstall
            set -e argv[1]
            set command "rm"

        case l ls list
            set -e argv[1]
            set command "ls"

        case h help
            set -e argv[1]
            __fin_help $argv

        case --help
            set -e argv[1]
            __fin_help

        case -h
            __fin_usage > /dev/stderr

        case -v --version
            set -l home ~
            printf "fin v$fin_version %s\n" (__fin_plugin_normalize_path (status -f) | command awk -v home="$home" '{ sub(home, "~") } //')
            return

        case -- ""
            set -e argv[1]

            if test -z "$argv"
                set command "default"
            else
                set command "install"
            end

        case self-destroy
            set -e argv[1]
            __fin_self_destroy $argv
            return

        case -\*\?
            printf "fin: '%s' is not a valid option\n" "$argv[1]" > /dev/stderr
            __fin_usage > /dev/stderr
            return 1

        case \*
            set command "install"
    end

    set -l items (
        if test ! -z "$argv"
            printf "%s\n" $argv | command awk '

                /^(--|-).*/ { next }

                /^omf\// {
                    sub(/^omf\//, "oh-my-fish/")

                    if ($0 !~ /(theme|plugin)-/) {
                        sub(/^oh-my-fish\//, "oh-my-fish/plugin-")
                    }
                }

                !seen[$0]++

            '
        end
    )

    if test -z "$items" -a "$command" = "default"
        if isatty
            touch "$fin_bundle"
            set items (__fin_read_bundle_file < "$fin_bundle")
            set command "install"

            if test -z "$items"
                __fin_log warn "
                    The bundle file is empty.
                    @$fish_config/bundle@
                " $__fin_stderr

                __fin_log says "

                    Your bundle keeps track of what's currently installed.
                    Write in the plugins you want and run fin again to
                    satisfy changes.

                    You can also install plugins using @fin plugin1 ...@
                " $__fin_stderr

                return 1
            end
        end
    end

    switch "$command"
        case install
            if __fin_install $items
                __fin_log says "Done in "(__fin_get_epoch_in_ms $elapsed | __fin_humanize_duration) $__fin_stderr
            end

        case update
            if isatty
                if test -z "$items"
                    __fin_self_update

                    set items (__fin_list | command sed 's/^[@* ]*//')
                end
            else
                __fin_parse_column_output | __fin_read_bundle_file | read -laz _items
                set items $items $_items
            end

            __fin_update $items

            __fin_log says "Done in "(__fin_get_epoch_in_ms $elapsed | __fin_humanize_duration) $__fin_stderr

        case ls
            if test "$argv" -ge 0 -o "$argv" = -
                set items (__fin_list)

                set -l count (count $items)

                if test "$count" -ge 10
                    printf "%s\n" $items | column -c$argv

                else if test "$count" -ge 1
                    printf "%s\n" $items
                end

            else
                __fin_list_plugin_directory $argv
            end

        case rm
            if test -z "$items"
                __fin_parse_column_output | __fin_read_bundle_file | read -az items
            end

            if test (count $items) -le 1
                function __fin_show_spinner
                end
            end

            if test ! -z "$items"
                for i in $items
                    set -l name (__fin_plugin_get_names "$i")[1]
                    __fin_plugin_disable "$fin_config/$name"
                    __fin_show_spinner
                end

                __fin_log says "Done in "(__fin_get_epoch_in_ms $elapsed | __fin_humanize_duration) $__fin_stderr
            end
    end

    complete -c fin --erase

    set -l config $fin_config/*
    set -l cache $fin_cache/*

    if test -z "$config"
        echo > $fin_bundle
    else
        __fin_plugin_get_url_info -- $config > $fin_bundle

        complete -xc fin -n "__fish_seen_subcommand_from u up update r rm remove uninstall" -a "(printf '%s\n' $config | command sed 's|.*/||')"
        complete -xc fin -n "__fish_seen_subcommand_from u up update r rm remove uninstall" -a "$fin_active_prompt" -d "Prompt"
    end

    if test ! -z "$cache"
        printf "%s\n" $cache | command awk -v _config="$config" '

            BEGIN {
                count = split(_config, config, " ")
            }

            {
                sub(/.*\//, "")

                for (i = 1; i <= count; i++) {
                    sub(/.*\//, "", config[i])

                    if (config[i] == $0) {
                        next
                    }
                }
            }

            //

        ' | while read -l plugin
            if __fin_plugin_is_prompt "$fin_cache/$plugin"
                complete -xc fin -n "__fish_seen_subcommand_from i in install" -a "$plugin" -d "Prompt"
                complete -xc fin -n "not __fish_seen_subcommand_from u up update r rm remove uninstall l ls list h help" -a "$plugin" -d "Prompt"
            else
                complete -xc fin -n "__fish_seen_subcommand_from i in install" -a "$plugin" -d "Plugin"
                complete -xc fin -n "not __fish_seen_subcommand_from u up update r rm remove uninstall l ls list h help" -a "$plugin" -d "Plugin"
            end
        end
    end

    set -l completions "$fish_config/completions/fin.fish"

    if test ! -e "$completions"
        __fin_completions_write > "$completions"
        source "$completions"
    end
end
