# nvm.fish

> Node.js version manager lovingly made for [Fish](https://fishshell.com).

Not [_that_](https://github.com/nvm-sh/nvm) POSIX-compatible script. Designed from the ground up for [Fish](https://fishshell.com), this tool helps you manage multiple active versions of Node on a single local environment. Quickly install and switch between runtimes without cluttering your home directory or breaking system-wide scripts.

- 100% pure Fish—quick & easy to contribute to or change
- <kbd>Tab</kbd>-completable seamless shell integration
- `.node-version` and `.nvmrc` support
- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) compliant
- No setup—it just works!

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

List which versions you have installed (includes your system-installed Node if there is one).

```console
$ nvm list
     system
    v8.17.0 lts/carbon
    v15.3.0 
 ▶ v14.15.1 lts/fermium
    v18.4.0 latest
```

Or list all the Node versions that can be installed.

```console
nvm list-remote
```

Want to uninstall a version?

```console
nvm uninstall v15.3.0
```

## `.nvmrc`

An `.nvmrc` file makes it easy to lock a specific version of Node for different projects. Just create an `.nvmrc` (or `.node-version`) file containing a version number or alias, e.g., `latest`, `lts`, `carbon`, in the root of your project.

```console
node --version >.nvmrc
```

Then run `nvm install` to install or `nvm use` to activate that version. Works from anywhere inside your project by traversing the directory hierarchy until an `.nvmrc` is found.

```console
nvm install
```

## `$nvm_mirror`

Use a mirror of the Node binaries. Default: https://nodejs.org/dist.

## `$nvm_default_version`

The `nvm install` command activates the specified Node version only in the current environment. If you want to set the default version for new shells use:

```fish
set --universal nvm_default_version v18.4.0
```

## `$nvm_default_packages`

If you have a list of default packages you want installed every time you install a new Node version use:

```fish
set --universal nvm_default_packages yarn np
```

## Acknowledgments

nvm.fish started out in 2016 by [@jorgebucaran](https://github.com/jorgebucaran) as Fish's premier choice to Node.js version management. All credit to [@creationx](https://github.com/creationix) and [@ljharb](https://github.com/ljharb) for creating the one true [nvm.sh](https://github.com/nvm-sh/nvm) that served as the inspiration for this project. If you are looking for a way to use the original nvm right from Fish, check out [@FabioAntunes/fish-nvm](https://github.com/FabioAntunes/fish-nvm) or [@derekstavis/plugin-nvm](https://github.com/derekstavis/plugin-nvm). Thank you to all our contributors! <3

## License

[MIT](LICENSE.md)
