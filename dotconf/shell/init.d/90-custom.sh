#!/bin/sh

if [ -z "${SOURCE_PATH}" ]; then return 1; fi
_PARENT="$(d=${SOURCE_PATH%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d." >/dev/null; pwd)"
_p="${_PARENT}/../custom.d"

export PATH="$(find "${_p}" -mindepth 2 -maxdepth 2 -type d -name 'bin' -not -path "${_p}/sample/*" | tr '\n' ':' | sed 's/:$//'):${PATH}"

_LF='
'
_IFS_BAK="${IFS}"
IFS="${_LF}"
for _file in $(find -L "${_p}" -mindepth 3 -maxdepth 3 -type f -name '*.sh' -path "${_p}/*/init.d/*" -not -path "${_p}/sample/*"); do
    SOURCE_PATH="${_file}" . "${_file}"
done
IFS="${_IFS_BAK}"
