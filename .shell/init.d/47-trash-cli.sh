#!/bin/sh

# コマンドの有無に合わせてディレクトリを自動作成
if type trash-put >/dev/null && [ ! -e "$HOME/.local/share/Trash" ]; then
    mkdir -p "$HOME/.local/share/Trash"
fi
