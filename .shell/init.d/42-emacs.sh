#!/bin/sh


if [ -n "$INSIDE_EMACS" ]; then
    # emacs内でemacsを開くときは既存のを使用
    export EDITOR=emacsclient
    alias emacs=editor-wrapper

    # データ詰まり解消
    if type explorer.exe >/dev/null 2>&1; then
        explorer.exe() {
            command explorer.exe "$@" | cat
        }
    fi
    if type cplex.exe >/dev/null 2>&1; then
        cplex.exe() {
            command cplex.exe "$@" | cat
        }
    fi
fi
