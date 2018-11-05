# fnm

[![Build Status](https://img.shields.io/travis/jorgebucaran/fnm.svg)](https://travis-ci.org/jorgebucaran/fnm)

> ✋ Psst! We're currently rewriting fnm—please subscribe to [issues/#75](https://github.com/jorgebucaran/fnm/issues/75) for and news & details.

Fnm is a node version manager using ideas from [tj/n](https://github.com/tj/n), [wbyoung/avn](https://github.com/wbyoung/avn) and [creationix/nvm](https://github.com/creationix/nvm) for the [fish-shell](https://fishshell.com).

## Features

- No sudo

- No configuration

- Cached downloads

- Automatic version switching

## Install

With [Fisher](https://github.com/jorgebucaran/fisher)

```
fisher add jorgebucaran/fnm
```

## Usage

Use node 5.5.0.

```fish
fnm 5.5.0
node -v
v5.5.0
```

Use a _.fnmrc_ file.

```fish
echo 5.10.1 > .fnmrc
node -v
v5.10.1
```

Use the latest stable node release.

```
fnm latest
```

Use the latest LTS (long-term support) node release.

```
fnm lts
```

Select a version interactively.

```
fnm
  5.5.0
  5.10.0
• 5.10.1
```

List all versions available for download.

```ApacheConf
fnm ls
  ...
- 5.5.0   # downloaded
  5.6.0
  ...
  5.9.1
- 5.10.0  # downloaded
• 5.10.1  # active version
```

Remove a version.

```
fnm rm 5.5.0
```

Customize the download mirror.

```fish
set -U fnm_mirror http://npm.taobao.org/mirrors/node
```

## License

Fnm is MIT licensed. See the [LICENSE](LICENSE) for details.
