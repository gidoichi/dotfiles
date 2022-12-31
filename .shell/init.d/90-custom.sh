#!/bin/sh

if [ -z "${SOURCE_PATH}" ]; then return 1; fi
_PARENT="$(d=${SOURCE_PATH%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d."; pwd)"

_LF='
'
_IFS_BAK="${IFS}"
IFS="${_LF}"
for _file in $(find "${_PARENT}/../custom.d" -type f -name '*.sh'); do
    SOURCE_PATH="${_file}" . "${_file}"
done
IFS="${_IFS_BAK}"
