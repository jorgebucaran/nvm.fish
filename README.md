[![Version][version-badge]][version-link]

[version-badge]: https://img.shields.io/badge/latest-v1.0.0-44cc11.svg?style=flat-square
[version-link]: https://github.com/fisherman/fin/releases

# fin

fin is a one-file, no-configuration, concurrent plugin manager for the fish shell.

## Why fin?

* One file

* No configuration

* No external dependencies

* No impact on shell startup time

* Use it interactively or _a la_ vundle

* Compatible with all the plugins of the ocean

* Only the essentials, install, update, remove, list and help

## Install

Copy `fin.fish` into your `~/.config/fish/functions` directory and that's it.

```sh
curl -Lo ~/.config/fish/functions/fin.fish --create-dirs git.io/fin
```

## Usage

Install a plugin.

```
fin simple
```

Install from multiple sources.

```
fin omf/{grc,thefuck} fzf z
```

Install from a URL.

```
fin https://github.com/edc/bass
```

Install from a gist.

```
fin https://gist.github.com/username/1f40e1c6e0551b2666b2
```

Install from a local directory.

```sh
fin ~/my_aliases
```

Use it a la vundle. Edit your bundle file and run `fin` to satisfy changes.

> [What is a bundle file and how do I use it?][bundle]

```sh
$EDITOR $fin_bundle # add plugins
fin
```

See what's installed.

```
fin ls
@ my_aliases    # this plugin is a local directory
* simple        # this plugin is the current prompt
  bass
  fzf
  grc
  thefuck
  z
```

Update everything.

```
fin up
```

Update some plugins.

```
fin up bass z fzf thefuck
```

Remove plugins.

```
fin rm simple
```

Remove everything.

```
fin ls | fin rm
```

Get help.

```
fin help z
```

## FAQ

### 1. How do I uninstall fin?

Run

```fish
fin self-destroy
```

### 2. What fish version is required?

fin was built for the latest fish, but at least 2.2.0 is required. If you can't upgrade your build, append the following code to your `~/.config/fish/config.fish` for [snippet](https://github.com/fisherman/fin/blob/master/faq.md#12-what-is-a-plugin) support.

```fish
for file in ~/.config/fish/conf.d/*.fish
    source $file
end
```

### 3. Is fin compatible with fisherman and oh my fish themes and plugins?

Yes.

### 4. Why fin? Why not ____?

fin learns from my mistakes building oh my fish, wahoo and fisherman. It also uses some ideas from fundle.

Other reasons:

* small and fits in one file

* zero impact on shell startup time

* fast and easy to install, update and uninstall

* no need to edit your fish configuration

* correct usage of the XDG base directory spec

### 5. Where does fin put stuff?

fin goes in `~/.config/fish/functions/fin.fish`.

The cache and plugin configuration is created in `~/.cache/fin` and `~/.config/fin` respectively.

The `bundle` file goes in `~/.config/fish/bundle` by default. Set `fin_bundle` to customize this location.

### 6. What is a bundle file and how do I use it?

The bundle file lists all the installed plugins.

You can let fin take care of the bundle for you automatically, or write in the plugins you want and run `fin` to satisfy the changes.

```
fisherman/simple
omf/grc
omf/thefuck
fisherman/z
```

This mechanism only installs plugins and missing dependencies. To remove a plugin, use `fin rm` instead.

The bundle file is inside your fish configuration directory `~/.config/fish` by default, but you can customize this location.

```
set -g fin_bundle ~/.bundle
```

### 7. Where can I find a list of fish plugins?

Browse the [organization], [awesome-fish], [oh-my-fish] or use the [online] search to discover content.

### 8. How do I install, update, list or remove plugins?

See [Usage].

### 9. How do I upgrade from ____?

You are not required to. fin does not interfere with other known frameworks. If you want to uninstall oh my fish or fisherman, refer to their documentation.

### 10. How do I update fin to the latest version?

Run

```
fin up
```

### 12. What is a plugin?

A plugin is:

1. a directory or git repo with a function `.fish` file either at the root level of the project or inside a `functions` directory

2. a theme or prompt, i.e, a `fish_prompt.fish`, `fish_right_prompt.fish` or both files

3. a snippet, i.e, one or more `.fish` files inside a directory named `conf.d` that are evaluated by fish at the start of the shell

### 13. How can I list plugins as dependencies to my plugin?

Create a new `bundle` file at the root level of your project and write in the plugin dependencies:

```fish
owner/repo
https://github.com/dude/sweet
https://gist.github.com/bucaran/c256586044fea832e62f02bc6f6daf32
```

### 14. I have a question or request not addressed here. Where should I put it?

Create a new ticket on the issue tracker:

* https://github.com/fisherman/fin/issues

### 15. Why did you create a new project instead of improving fisherman?

1. fisherman uses an index file and has built-in search capabilities / advanced completions that are not  compatible with fin's simpler model
2. I wanted a clean slate and a chance to experiment with something different
3. fin is more opinionated and pragmatic than fisherman, thus truer to fish [configurability] principle

### 16. What about fundle?

fundle inspired me to use a bundle and one-file distribution, but it has limited capabilities and still requires you to edit your fish configuration.

[organization]: https://github.com/fisherman
[oh-my-fish]: https://github.com/oh-my-fish
[awesome-fish]: https://github.com/bucaran/awesome-fish
[online]: http://fisherman.sh/#search
[Usage]: https://github.com/fisherman/fin#usage
[configurability]: http://fishshell.com/docs/current/design.html#design-configurability
[bundle]: https://github.com/fisherman/fin#6-what-is-a-bundle-file-and-how-do-i-use-it
