#!/bin/zsh

if ! type basher >/dev/null 2>&1; then
    return 1
fi

eval "$(basher init - zsh)"
