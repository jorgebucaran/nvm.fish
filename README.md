# nvm.fish

> The Node.js version manager you'll adore, crafted just for [Fish](https://fishshell.com).

Nope, not [_that_](https://github.com/nvm-sh/nvm) POSIX-compatible script. Built from scratch for [Fish](https://fishshell.com), this handy tool lets you juggle multiple active Node versions in a single local environment. Install and switch between runtimes like a boss, without messing up your home directory or breaking system-wide scripts.

- 100% pure Fish—so simple to contribute to or tweak
- <kbd>Tab</kbd>-completable for seamless shell integration
- `.node-version` and `.nvmrc` support
- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) compliant
- No setup needed—it just works!

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install jorgebucaran/nvm.fish
```

## Quickstart

Install the latest Node release and activate it.

```console
nvm install latest
```

Install the latest [LTS](https://github.com/nodejs/Release) (long-term support) Node release.

```console
nvm install lts
```

Install an older LTS release by codename.

> Installs `8.16.2`, the latest release of the Carbon LTS line.

```console
nvm install carbon
```

Or install a specific version of Node.

> Supports full or partial version numbers, starting with an optional "v".

```console
nvm install v15.3.0
```

Activate a version you've already installed.

```console
nvm use v14
```

Check out which versions you have installed (includes your system-installed Node if there is one).

```console
$ nvm list
     system
    v8.17.0 lts/carbon
    v15.3.0
 ▶ v14.15.1 lts/fermium
    v18.4.0 latest
```

Or list all the Node versions up for grabs.

```console
nvm list-remote
```

Need to uninstall a version?

```console
nvm uninstall v15.3.0
```

## `.nvmrc`

An `.nvmrc` file is perfect for locking a specific version of Node for different projects. Just create an `.nvmrc` (or `.node-version`) file with a version number or alias, e.g., `latest`, `lts`, `carbon`, in your project's root.

```console
node --version >.nvmrc
```

Then run `nvm install` to install or `nvm use` to activate that version. Works like a charm from anywhere in your project by traversing the directory hierarchy until an `.nvmrc` is found.

```console
nvm install
```

## `$nvm_mirror`

Choose a mirror of the Node binaries. Default: https://nodejs.org/dist.

## `$nvm_default_version`

The `nvm install` command activates the specified Node version only in the current environment. If you want to set the default version for new shells:

```fish
set --universal nvm_default_version v18.4.0
```

## `$nvm_default_packages`

Got a list of default packages you want installed every time you install a new Node version?

```fish
set --universal nvm_default_packages yarn np
```

## `$nvm_dir`

If you want to set nvm's installation directory for storing Node versions:

```fish
set --universal nvm_dir $HOME/.nvm
```

## Acknowledgments

`nvm.fish` was established in 2016 by [**@jorgebucaran**](https://github.com/jorgebucaran) as the go-to Node.js version manager for Fish. It was inspired by the original [**nvm.sh**](https://github.com/nvm-sh/nvm) created by [**@creationix**](https://github.com/creationix) and [**@ljharb**](https://github.com/ljharb). To use the original nvm in Fish, consider [**@FabioAntunes/fish-nvm**](https://github.com/FabioAntunes/fish-nvm) or [**@derekstavis/plugin-nvm**](https://github.com/derekstavis/plugin-nvm). We appreciate all of our contributors! ❤️

## License

[MIT](LICENSE.md)
