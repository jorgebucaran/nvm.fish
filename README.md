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

```console
nvm install carbon
```

> Installs `8.16.2`, the latest release of the Carbon LTS line.

Or install a specific version of Node.

```console
nvm install v12.9.1
```

> Supports full or partial version numbers, starting with an optional "v".

The `nvm install` command activates the specified Node version only in the current environment. If you want to set the default version for new shells use:

```fish
set --universal nvm_default_version v12.9.1
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
    v12.9.1
 ▶ v14.15.1 lts/fermium
    v15.3.0 latest
```

Or list all the Node versions available to install.

```console
nvm list-remote
```

Want to uninstall a Node version?

```console
nvm uninstall v12.9.1
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

### Automatic activation

Switching to the version specified by the current working project can be enable with:

```console
set --universal nvm_use_on_pwd_change true
```

## `$nvm_mirror`

If you would like to use a different Node.js mirror that has the same layout as the default at https://nodejs.org/dist, you can set `$nvm_mirror`. A typical example is users from China using:

```console
set --universal nvm_mirror https://npm.taobao.org/mirrors/node
```

## Acknowledgments

nvm.fish started out in 2016 by [@jorgebucaran](https://github.com/jorgebucaran) as Fish's premier choice to Node.js version management. A heartfelt thank you to [@creationx](https://github.com/creationix) and [@ljharb](https://github.com/ljharb) for creating the one true [nvm.sh](https://github.com/nvm-sh/nvm) that served as the inspiration for this project. If you are looking for a way to use the original nvm right from Fish, check out [@FabioAntunes/fish-nvm](https://github.com/FabioAntunes/fish-nvm) or [@derekstavis/plugin-nvm](https://github.com/derekstavis/plugin-nvm). Thank you to all our contributors! <3

## License

[MIT](LICENSE.md)
