#!/bin/sh

PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d."; pwd)"

PATH="${HOME}/.local/bin:${PATH}"
PATH="${PARENT}/../bin:${PATH}"

target="${CARGO_HOME:-${HOME}/.cargo}/bin"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi

target="${HOME}/.emacs.d/bin"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi

export GOPATH="${GOPATH:-${HOME}/go}"
target="${GOPATH}/bin"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi

if type ghq >/dev/null; then
    GHQ_ROOT="$(ghq root)"
fi

target="${HOME}/.npm/bin"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi

export HOMEBREW_HOME="${HOMEBREW_HOME:-${HOME}/.homebrew}"
target="${HOMEBREW_HOME}/bin"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi
target="${GHQ_ROOT:+${GHQ_ROOT}/github.com/Homebrew/brew/bin}"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi

target="${GHQ_ROOT:+${GHQ_ROOT}/github.com/gidoichi/pmo/bin}"
if [ -d "${target}" ]; then export PATH="${target}:${PATH}"; fi
