#!/bin/sh

# windows
if type explorer.exe wslpath >/dev/null; then
    # explorerの引数に与えるファイルをWindows用のパスに変換する
    explorer() {
        if [ $# -eq 0 ]; then
            explorer.exe
            return
        fi

        _file="${1:-}"

        # 引数の実態確認
        if [ ! -e "${_file}" ]; then
            ls -- "${_file}" 2>&1 | cut -d ' ' -f 2- | sed "s/^/$0: /" >&2
            return
        fi

        # readlinkを用いた方法
        if type readlink >/dev/null; then
            _file="$(readlink -f "${_file}")"
            win="$(wslpath -w "${_file}")"
            explorer.exe "${win}"
            return
        fi

        # エラー
        readlink
    }
fi

# mac
if ! alias date >/dev/null 2>&1 &&
   type gdate   >/dev/null 2>&1; then
    alias date='gdate'
fi
if ! alias ls >/dev/null 2>&1 &&
   type gls   >/dev/null 2>&1; then
    alias ls='gls'
fi
if ! alias timeout >/dev/null 2>&1 &&
   type gtimeout   >/dev/null 2>&1; then
    alias timeout='gtimeout'
fi
