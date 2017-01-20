# fnm

[![][travis-badge]][travis-link]
[![][slack-badge]][slack-link]

fnm is a node version manager using ideas from [tj/n], [wbyoung/avn] and [creationix/nvm] for [fish].

## Features

* No sudo

* No configuration

* Cached downloads

* Automatic version switching

## Install

With [fisherman]

```
fisher fnm
```

## Usage

Use node 5.5.0.

```fish
fnm 5.5.0
node -v
v5.5.0
```

Use a *.fnmrc* file.

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

[fisherman]: https://github.com/fisherman
[tj/n]: https://github.com/tj/n
[wbyoung/avn]: https://github.com/wbyoung/avn
[creationix/nvm]: https://github.com/creationix/nvm
[fish]: https://fishshell.com

[slack-link]: https://fisherman-wharf.herokuapp.com
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg
[travis-link]: https://travis-ci.org/fisherman/fisherman
[travis-badge]: https://img.shields.io/travis/fisherman/fisherman.svg
