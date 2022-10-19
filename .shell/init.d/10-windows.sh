#!/bin/sh

if type cmd.exe >/dev/null 2>&1; then
    cmd.exe() {
        command cmd.exe $@ | cat
    }
fi

if type explorer.exe wslpath >/dev/null 2>&1; then
    # explorerの引数に与えるファイルをWindows用のパスに変換する
    explorer() {
        if [ $# -eq 0 ]; then
            explorer.exe
            return
        fi

        local file="${1:-}"

        # 引数の実態確認
        if [ ! -e "$file" ]; then
            ls "$file" 2>&1 | cut -d ' ' -f 2- | sed "s/^/$0: /" >&2
            return
        fi

        # readlinkを用いた方法
        if type readlink >/dev/null 2>&1; then
            local file=$(readlink -f "$file")
            win="$(wslpath -w "$file")"
            explorer.exe "${win}"
            return
        fi

        # エラー
        readlink
    }
fi

if type powershell.exe >/dev/null 2>&1; then
    powershell.exe() {
        command powershell.exe $@ | cat
    }
fi
