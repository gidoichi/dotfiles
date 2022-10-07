#!/bin/sh

export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/.shell/bin:${PATH}"

if type emacs >/dev/null 2>&1; then
    export EDITOR=emacs
fi

if [ -d "${HOME}/.cargo/bin" ]; then
    export PATH="${HOME}/.cargo/bin:${PATH}"
fi

if [ -d "${HOME}/.emacs.d/bin" ]; then
    export PATH="${HOME}/.emacs.d/bin:${PATH}"
fi

export GOPATH="${GOPATH:-${HOME}/go}"
if [ -d "${GOPATH}/bin" ]; then
    export PATH="${GOPATH}/bin:${PATH}"
fi

if type ghq >/dev/null 2>&1; then
    if [ -d "$(ghq root)/github.com/Homebrew/brew/bin" ]; then
        export PATH="$(ghq root)/github.com/Homebrew/brew/bin:${PATH}"
    fi
fi

export NPM_HOME="${NPM_HOME:-${HOME}/.npm}"
if [ -d "${NPM_HOME}/bin" ]; then
    export PATH="${NPM_HOME}/bin:${PATH}"
fi

export LC_COLLATE=ja_JP.UTF-8

if type screen >/dev/null 2>&1; then
    export SCREENDIR="${HOME}/.screen"
fi

if type fzf >/dev/null 2>&1; then
    export LINE_SELECTOR=fzf
elif type lnum-select >/dev/null 2>&1; then
    export LINE_SELECTOR=lnum-select
fi

export HOMEBREW_HOME="${HOMEBREW_HOME:-${HOME}/.homebrew}"
if [ -d "${HOMEBREW_HOME}/bin" ]; then
    export PATH="${HOMEBREW_HOME}/bin:${PATH}"
fi

export ONELINE_SELECTOR=1line-select

if [ -d "$(ghq root)/github.com/gidoichi/pmo/bin" ]; then
    export PATH="$(ghq root)/github.com/gidoichi/pmo/bin:${PATH}"
fi
