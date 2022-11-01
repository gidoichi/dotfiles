#!/bin/sh

_LF='
'

_PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d."; pwd)"
_IFS_BAK="${IFS}"
IFS="${_LF}"
for _file in $(find "${_PARENT}/../custom.d" -type f -name '*.sh'); do
    . "${_file}"
done
IFS="${_IFS_BAK}"
