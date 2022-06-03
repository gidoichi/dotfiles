#!/bin/sh

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.shell/bin:$PATH"

if type emacs >/dev/null 2>&1; then
    export EDITOR=emacs
fi

if [ -d "$HOME/.emacs.d/bin" ]; then
    export PATH="$HOME/.emacs.d/bin:$PATH"
fi

if type go >/dev/null 2>&1; then
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$PATH"
fi

if type npm >/dev/null 2>&1; then
    export PATH="$HOME/.npm/bin:$PATH"
fi

export LC_COLLATE=ja_JP.UTF-8

if type screen >/dev/null 2>&1; then
    export SCREENDIR="$HOME/.screen"
fi

if type fzf >/dev/null 2>&1; then
    export LINE_SELECTOR=fzf
elif type lnum-select >/dev/null 2>&1; then
    export LINE_SELECTOR=lnum-select
fi

export ONELINE_SELECTOR=1line-select
