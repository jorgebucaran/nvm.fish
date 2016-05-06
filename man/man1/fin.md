fin(1) -- node.js version manager
=================================

## SYNOPSIS

`fin` [*command*] [*version*] [--help] [--version]<br>

where command can be one of: `u`se (optional), `l`s and `r`m.

## DESCRIPTION

**fin** is a node version manager using ideas from tj/n, wbyoung/avn and creationix/nvm for fish-shell.

## USAGE

Use node 5.5.0.

```fish
fin 5.5.0
node -v
v5.5.0
```

Use a *.finrc* file.

```fish
echo 5.10.1 > .finrc
node -v
v5.10.1
```

Use the latest stable node release.

```
fin latest
```

Use the latest LTS (long-term support) node release.

```
fin lts
```

Select a version interactively.

```
fin
  5.5.0
  5.10.0
* 5.10.1
```

List all versions available for download.

```
fin ls
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
fin rm 5.5.0
```
