# zim-aws-sso-cli

[zim module](https://github.com/zimfw/zimfw) for [aws-sso](https://synfinatic.github.io/aws-sso-cli)

## Features

- `aws-sso-profile [-S <sso>] <profile>` and `aws-sso-clear`, aws-sso's own shell
  helpers: they set and clear `AWS_*` in the current shell. Generated from
  `aws-sso setup completions --source`, so they follow each aws-sso release.
- Completion for `aws-sso-profile`: profiles one part at a time, split on `:`
  (`Account:Role`), from the SSO instance `-S` names, else the default one.
- Completion for `aws-sso` itself, its commands and flags, without `bashcompinit`.

## Install

Add it to `~/.zimrc` after the module that puts `aws-sso` on your `PATH` (e.g.
`zim-mise`), then run `zimfw install`:

```zsh
zmodule muchobien/zim-aws-sso-cli
```

Needs aws-sso 2 (`setup completions --source`). Installed through mise or asdf
works too, even when only their shims are on `PATH`: the module finds the real
binary with `mise which` / `asdf which`.

## Configuration

- `AWS_SSO_HELPER_ARGS`: the arguments the helpers and completions pass to
  aws-sso, `-L error` by default.

The helpers are generated into `aws-sso-init.zsh` in the module's directory, again
whenever aws-sso or the module is updated.
