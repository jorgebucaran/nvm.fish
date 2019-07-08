# fish-nvm (Node Version Manager) [![Releases](https://img.shields.io/github/release/jorgebucaran/fish-nvm.svg?label=&color=0080FF)](https://github.com/jorgebucaran/fish-nvm/releases/latest)

> Pure-[fish](https://fishshell.com), Node.js version manager.

- `.nvmrc` support.
- Seamless shell integration.
  - <kbd>Tab</kbd>-completions? You got it.
- No dependencies, no subshells, and no configuration setup—it just works.
- Basically pretty easy to use, minimal & awesome ([see this comparison](https://github.com/jorgebucaran/fish-nvm/issues/82)).

![](https://gitcdn.link/repo/jorgebucaran/00f6d3f301483a01a00e836eb17a2b3e/raw/0084c9bacd4dcc8ddea0932d413efcab98f3b82f/fish-nvm.svg)

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher) (recommended):

```
fisher add jorgebucaran/fish-nvm
```

<details>
<summary>Not using a package manager?</summary>

---

Copy [`conf.d/nvm.fish`](conf.d/nvm.fish), [`functions/nvm.fish`](functions/nvm.fish), and [`completions/nvm.fish`](completions/nvm.fish) to your fish configuration directory preserving the directory structure.

```fish
set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config

for i in conf.d functions completions
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

Download and switch to the latest Node.js release.

```fish
nvm use latest
```

> **Note:** This downloads the latest Node.js release tarball from the [official mirror](https://nodejs.org/dist), extracts it to <code>[\$XDG_CONFIG_HOME](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables)/nvm</code> and modifies your `$PATH` so it can be used immediately. Learn more about the Node.js release schedule [here](https://github.com/nodejs/Release).

Download and switch to the latest LTS (long-term support) Node.js release.

```
nvm use lts
```

You can create a `.nvmrc` file in the root of your project (or any parent directory) and run `nvm` to use the version in it. `nvm` will try to find the nearest `.nvmrc` file, traversing the directory tree from the current working directory upwards.

```fish
node -v > .nvmrc
nvm
```

Run `nvm` in any subdirectory of a directory with an `.nvmrc` file to switch to the version from that file. Similarly, running `nvm use <version>` updates that `.nvmrc` file with the specified version.

```
├── README.md
├── dist
├── node_modules
├── package.json
└── src
    └── index.js
```

```fish
echo lts >.nvmrc
cd src
nvm
node -v
v10.15.1
```

### Listing versions

List all the supported Node.js versions you can download and switch to.

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

To customize the download mirror, e.g., if you are behind a firewall, you can set `$nvm_mirror`:

```fish
set -g nvm_mirror http://npm.taobao.org/mirrors/node
```

## License

[MIT](LICENSE.md)
