# nvm.fish

> Node version manager lovingly made for [Fish](https://fishshell.com).

Not [_that_](https://github.com/nvm-sh/nvm) POSIX-compatible script. Designed for [Fish](https://fishshell.com), this tool helps you manage multiple active versions of Node on a single local environment. Quickly install and switch between runtimes without cluttering your home directory or breaking system-wide scripts. 

- No dependencies, no setup, no clutter—it just works.
- 100% Fish—quick & easy to contribute to or change.
- <kbd>Tab</kbd>-completable seamless shell integration.
- `.node-version` and `.nvmrc` support. ✅
- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) compliant.

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```console
fisher install jorgebucaran/nvm.fish
```

## Quickstart

Install the latest Node release and start using it.

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
nvm use lts
```

List which versions you have installed (includes any previously installed system Node if there is one).

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

Want to remove a Node version? You can do that too.

```console
nvm uninstall v12.9.1
```

## `.nvmrc`

An `.nvmrc` file makes it easy to peg a specific version of Node for different projects. Just create an `.nvmrc` (or `.node-version`) file containing a version number or alias, e.g., `latest`, `lts`, `carbon`, in the root of your project.

```console
node -v >.nvmrc
```

Then run `nvm install` to install or `nvm use` to activate that version. Works from anywhere inside your project by traversing the directory hierarchy until an `.nvmrc` is found!

```console
nvm install
```

## License

[MIT](LICENSE.md)
