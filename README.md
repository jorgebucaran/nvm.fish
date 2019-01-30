# fish-nvm (Node.js Version Manager)

[![Build Status](https://img.shields.io/travis/jorgebucaran/fish-nvm.svg)](https://travis-ci.org/jorgebucaran/fish-nvm)
[![Releases](https://img.shields.io/github/release/jorgebucaran/fish-nvm.svg?label=latest)](https://github.com/jorgebucaran/fish-nvm/releases)

Node.js version manager for the <a href=https://fishshell.com title="friendly interactive shell">fish shell</a>.

![](https://gitcdn.link/repo/jorgebucaran/00f6d3f301483a01a00e836eb17a2b3e/raw/cb8e0a4b5a46fe032f5c3a154ffdb0c141898dbb/fish-nvm.svg)

## Features

- `.nvmrc` support
- Seamless shell integration
  - <kbd>Tab</kbd>-completions? You got it
- No dependencies, no subshells, no configuration setup—it just works

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher) (recommended):

```
fisher add jorgebucaran/fish-nvm
```

<details>
<summary>Not using a package manager?</summary>

---

Copy [`conf.d/nvm.fish`](conf.d/nvm.fish), [`functions/nvm.fish`](functions/nvm.fish), and [`completions/nvm.fish`](completions/nvm.fish) to your fish configuration directory preserving directory structure.

```fish
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config

for i in {conf.d,functions,completions}
  curl https://git.io/$i.nvm.fish --create-dirs -sLo $XDG_CONFIG_HOME/fish/$i/nvm.fish
end
```

To uninstall, run the following code:

```
rm -f $XDG_CONFIG_HOME/fish/{conf.d,functions,completions}/nvm.fish && emit nvm_uninstall
```

</details>

### System Requirements

- [fish](https://github.com/fish-shell/fish-shell) 2.2+
- [curl](https://github.com/curl/curl) [7.10.3](https://curl.haxx.se/changes.html#7_10_3)+

## Usage

This will download the latest Node.js release tarball from the [official mirror](https://nodejs.org/dist), extract it to <code>[\$XDG_CONFIG_HOME](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables)/nvm</code> and modify your `$PATH` so it can be used immediately. Learn more about the Node.js release schedule [here](https://github.com/nodejs/Release).

```fish
nvm use latest
```

This will download and use the latest LTS (long-term support) Node.js release.

```
nvm use lts
```

You can create an `.nvmrc` file in the root of your project (or any parent directory) and run `nvm` to use the version in it. We'll attempt to find the nearest `.nvmrc` file, traversing the directory tree from the current working directory upwards.

```fish
echo 10 >.nvmrc
nvm
```

Running `nvm` in any subdirectory of a directory with an `.nvmrc` file will use the version from that file. Likewise, running `nvm use <version>` will update that `.nvmrc` file with the specified version.

```
├── README.md
├── dist
    └── foo.min.js
├── node_modules
├── package.json
└── src
    └── index.js
```

```fish
echo 10 >.nvmrc
cd src
nvm
node -v
10.15.0
```

List all supported Node.js versions you can download and use.

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

You can use a regular expression to narrow down the output.

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
