#!/bin/sh

LN='
'

PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d."; pwd)"
IFS_BAK="${IFS}"
IFS="${LN}"
for file in $(find "${PARENT}/../custom.d" -type f -name '*.sh'); do
    . "${file}"
done
IFS="${IFS_BAK}"
