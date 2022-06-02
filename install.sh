#!/bin/sh

PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d"; pwd)"

find "$PARENT/" -mindepth 1 -maxdepth 1 -name '.*' -not -name '.git' |
sed 's#^.*/##' |
xargs -I {} ln -sf "$PARENT/{}" "$HOME/{}"
