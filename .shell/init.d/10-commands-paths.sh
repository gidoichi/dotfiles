#!/bin/sh

if [ -z "${SOURCE_PATH}" ]; then return 1; fi
_PARENT="$(d=${SOURCE_PATH%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d." >/dev/null; pwd)"

PATH="${HOME}/.local/bin:${PATH}"
PATH="${_PARENT}/../bin:${PATH}"

_target="${CARGO_HOME:-${HOME}/.cargo}/bin"
if [ -d "${_target}" ]; then export PATH="${_target}:${PATH}"; fi

_target="${HOME}/.emacs.d/bin"
if [ -d "${_target}" ]; then export PATH="${_target}:${PATH}"; fi

export GOPATH="${GOPATH:-${HOME}/go}"
_target="${GOPATH}/bin"
if [ -d "${_target}" ]; then export PATH="${_target}:${PATH}"; fi

if type ghq >/dev/null; then
    GHQ_ROOT="$(ghq root)"
fi

_target="/home/linuxbrew/.linuxbrew/bin"
if [ -d "${_target}" ]; then export PATH="${PATH}:${_target}"; fi
if type brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi

_target="${HOME}/.npm/bin"
if [ -d "${_target}" ]; then export PATH="${_target}:${PATH}"; fi

if type asdf >/dev/null 2>&1; then
    export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:${PATH}"
fi
