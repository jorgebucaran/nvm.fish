[slack-link]: https://fisherman-wharf.herokuapp.com
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg
[travis-link]: https://travis-ci.org/fisherman/fisherman
[travis-badge]: https://img.shields.io/travis/fisherman/fisherman.svg

[![][travis-badge]][travis-link]
[![][slack-badge]][slack-link]

# fin

fin is a node version manager using ideas from [tj/n], [wbyoung/avn] and [creationix/nvm] for the fish shell.

## Features

* No sudo

* Autocomplete

* No configuration

* Cached downloads

* Automatic version switching

## Install

With [fisherman]

```
fisher fin
```

## Usage

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

```ApacheConf
fin
  5.5.0
  5.10.0
• 5.10.1
```

List all versions available for download.

```ApacheConf
fin ls
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
fin rm 5.5.0
```

## Bugs

fin was built for fish >= 2.3.0. If you are using fish 2.2.0, append the following code to your ~/.config/fish/config.fish for automatic version switching support.

```fish
for file in ~/.config/fish/conf.d/*.fish
    source $file
end
```

[bass]: https://github.com/edc/bass
[laborious]: https://github.com/edc/bass/issues/28
[fisherman]: https://github.com/fisherman
[tj/n]: https://github.com/tj/n
[wbyoung/avn]: https://github.com/wbyoung/avn
[creationix/nvm]: https://github.com/creationix/nvm
