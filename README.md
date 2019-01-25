# fish-nvm (Node.js Version Manager)

[![Build Status](https://img.shields.io/travis/jorgebucaran/fish-nvm.svg)](https://travis-ci.org/jorgebucaran/fish-nvm)
[![Releases](https://img.shields.io/github/release/jorgebucaran/fish-nvm.svg?label=latest)](https://github.com/jorgebucaran/fish-nvm/releases)

fish-nvm is a Node.js version manager for the [fish shell](https://fishshell.com).

![](https://gitcdn.link/repo/jorgebucaran/c796a54376c7571ad7d5bb1c85feabb8/raw/038b6654300e4575b47c0a61a749733ea9c0bb5d/nvm.svg)

## Features

- Zero configuration, pure-fish, binary management
- No subshells, no dependencies, no nonsense
- <kbd>Tab</kbd> completions included out of the box

## Installation

<pre>
<a href=https://github.com/jorgebucaran/fisher>fisher</a> add jorgebucaran/fish-nvm
</pre>

### Manual Installation

Download `nvm.fish` to your fish configuration directory to install (or upgrade) nvm manually. If `nvm` is not immediately available after the download, you can launch a new session, or [replace the current session](https://fishshell.com/docs/current/commands.html#exec) with a new one.

```fish
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config

for i in {conf.d,functions,completions}
  curl https://git.io/$i.nvm.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/$i/nvm.fish
end
```

To uninstall nvm from your system run this code.

```
rm -f $XDG_CONFIG_HOME/fish/{conf.d,functions,completions}/nvm.fish && emit nvm_uninstall
```

### System Requirements

- [fish](https://github.com/fish-shell/fish-shell) 2.2+
- [curl](https://github.com/curl/curl) 7.10.3+

## Usage

This will download the latest Node.js release tarball from the [official mirror](https://nodejs.org/dist), extract it to <code>[\$XDG_CONFIG_HOME](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables)/nvm</code> and modify your `$PATH` so it can be used right away. Learn more about the Node.js release schedule [here](https://github.com/nodejs/Release).

```fish
nvm use latest
```

This will download and use the latest LTS (long-term support) Node.js release.

```
nvm use lts
```

You can create a `.nvmrc` file in the root of your project (or any parent directory) and run `nvm` to use the version contained in it. Running this in any subdirectory of a directory with an `.nvmrc` will result in that `.nvmrc` being used.

```fish
echo 10 > .nvmrc
nvm
```

List all supported Node.js versions.

```
nvm ls
```

```console
...
10.14.2    (lts/dubnium)
10.15.0    (lts/dubnium)
 11.0.0
 11.1.0
 11.2.0
 11.3.0
 11.4.0
 11.5.0
 11.6.0
 11.7.0    (latest/current)
```

Want to narrow that down a bit? You can use a regular expression to refine the output.

```
nvm ls '^8.[4-6]'
```

```console
8.4.0    (lts/carbon)
8.5.0    (lts/carbon)
8.6.0    (lts/carbon)
```

Are you behind a firewall? Use the `$nvm_mirror` variable to customize the download mirror.

```fish
set -g nvm_mirror http://npm.taobao.org/mirrors/node
```

## License

[MIT](LICENSE.md)
