質問ではない。
================

[![Build Status](https://travis-ci.org/rhysd/ezoe.svg)](https://travis-ci.org/rhysd/ezoe)

![screenshot](https://raw.githubusercontent.com/rhysd/screenshots/master/ezoe/ezoe.png)

[`ezoe` command](http://mattn.kaoriya.net/software/lang/go/20150520134340.htm) implemented with [Crystal](http://crystal-lang.org/).

## Usage

- Show questions and answers corresponding to.

```
$ ezoe
```

- Post a question.

```
$ ezoe ビム？イーマクス？
```

You can change the user by `-u {user}` option. Default user is [EzoeRyou](http://ask.fm/EzoeRyou).

## Installation

1. Install `crystal` compiler following [the instruction](http://crystal-lang.org/docs/installation/index.html).
2. Execute `$ crystal build --release /path/to/ezoe/src/ezoe.cr` to generate executable or `$ crystal --release  /path/to/ezoe/src/ezoe.cr` to run.

It seems that Crystal is not ready for Windows.  [Cross compilation](http://crystal-lang.org/docs/syntax_and_semantics/cross-compilation.html) may be available.

## Other `ezoe` implementations

- [golang](https://github.com/mattn/ezoe)
- [Haskell](https://github.com/tanakh/ezoe)
- [Clojure](https://github.com/mattn/clj-ezoe)
- [Rust](https://github.com/woxtu/rust-ezoe)

You may be able to find more implementations of `ezoe` in [awesome-ezoe](https://github.com/mattn/awesome-ezoe).

## License

Distributed under [the MIT License](http://opensource.org/licenses/MIT)

```
Copyright (c) 2015 rhysd
```

