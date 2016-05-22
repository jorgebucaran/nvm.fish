fnm(1) -- node.js version manager
=================================

## SYNOPSIS

`fnm` [*command*] [*version*] [--help] [--version]<br>

where command can be one of: `u`se (optional), `l`s and `r`m.

## DESCRIPTION

**fnm** is a node version manager using ideas from tj/n, wbyoung/avn and creationix/nvm for fish-shell.

## USAGE

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
* 5.10.1
```

List all versions available for download.

```
fnm ls
  ...
- 5.5.0   # downloaded
  5.6.0
  ...
  5.9.1
- 5.10.0  # downloaded
* 5.10.1  # active version
```

Remove a version.

```
fnm rm 5.5.0
```

## OPTIONS

Customize the download mirror.

```
set -u fnm_mirror http://npm.taobao.org/mirrors/node
```
