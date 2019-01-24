# fish-nvm — Node.js Version Manager

[![Build Status](https://img.shields.io/travis/jorgebucaran/fish-nvm.svg)](https://travis-ci.org/jorgebucaran/fish-nvm)
[![Releases](https://img.shields.io/github/release/jorgebucaran/fish-nvm.svg?label=latest)](https://github.com/jorgebucaran/fish-nvm/releases)

fish-nvm is a Node.js version manager for the [fish shell](https://fishshell.com).

![](https://gitcdn.link/repo/jorgebucaran/c796a54376c7571ad7d5bb1c85feabb8/raw/038b6654300e4575b47c0a61a749733ea9c0bb5d/nvm.svg)

## Features

- Zero configuration, pure-fish binary management
- No subshells, no dependencies, no nonsense
- <kbd>Tab</kbd> completions included out-of-the-box

## Installation

```sh
fisher add jorgebucaran/fish-nvm
```

## System Requirements

- [fish](https://github.com/fish-shell/fish-shell) 2.2+
- [curl](https://github.com/curl/curl) 7.10.3+

## Usage

Use a node version. This will download the node binary tarball from the [default mirror](https://nodejs.org/dist/) and modify your `$PATH` so you can start using it right away.

```fish
nvm use 10
node -v
v10.15.0
```

Use the latest node release. Learn more about release schedules [here](https://github.com/nodejs/Release).

```
nvm use latest
```

Use the latest LTS (long-term support) node release.

```
nvm use lts
```

Create an `.nvmrc` file in the root of your project and run `nvm` to use the version in it. 

```fish
echo latest > .nvmrc
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
$ nvm ls '^8.[4-6]'
8.4.0    (lts/carbon)
8.5.0    (lts/carbon)
8.6.0    (lts/carbon)
```

Are you behind a firewall? Use the `$nvm_mirror` variable to customize the download mirror.

```fish
set -g nvm_mirror http://npm.taobao.org/mirrors/node
```

## License

Copyright © 2016-2019 Jorge Bucaran <<https://jorgebucaran.com>>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
