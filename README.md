# NVM.fish

> 100% pure-[Fish](https://fishshell.com) Node version management.

Not [_that_](https://github.com/nvm-sh/nvm) POSIX-compatible script. Designed for [Fish](), this tool helps you manage different versions of Node on a single local environment. Quickly install and switch between runtimes without cluttering your home directory or breaking system-wide scripts. Here are some of the highlights:

- [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) friendly.
- `.node-version` and `.nvmrc` support. ✅
- <kbd>Tab</kbd>-completable seamless shell integration.
- No dependencies, no setup, no clutter—it just works.
  <!-- - Hot symlink switching—absolute speed unlocked. -->
    <!-- - Automatic version switching on `$PWD` change. -->

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
set -U nvm_default_version v12.9.1
```

Activate a version you've already installed.

```console
nvm use lts
```

List which versions you have installed (including the system Node if there is one).

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
$ nvm list-remote
   ...
   v14.13.1  
   v14.14.0  
   v14.15.0 lts/fermium 
 ▶ v14.15.1 lts/fermium ✓
    v15.0.0  
    v15.0.1  
    v15.1.0  
    v15.2.0  
    v15.2.1  
    v15.3.0 latest ✓
```

Want to remove a Node version? You can do that too.

```console
nvm remove v12.9.1
```

If you would like to use a different mirror of the Node binaries, for example, if you're behind a firewall, use:

```fish
set -g nvm_mirror https://npm.taobao.org/mirrors/node
```

## `.nvmrc`

An `.nvmrc` file makes it easy to peg a specific version of Node for different projects. Just create an `.nvmrc` file containing a Node version number or alias, e.g., `node`, `lts`, `carbon`, etc., in the root of your project.

```console
node -v >.nvmrc
```

Then run `nvm install` to install and activate that version. This will traverse the directory hierarchy looking for the nearest `.nvmrc` file.

```console
nvm install
```

## License

[MIT](LICENSE.md)
