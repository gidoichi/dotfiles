#!/bin/sh

PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d"; pwd)"

IFSORG="${IFS}"
IFS="$(printf '\n_')"
IFS="${IFS%_}"
rc=0
for file in $(find "${PARENT}/" -mindepth 1 -maxdepth 1 -name '.*' -not -name '.git' |
               sed 's#^.*/##'); do
    if [ -L "${HOME}/${file}" ] >/dev/null; then
        inode_org="$(ls -di "${PARENT}/${file}" | cut -d ' ' -f 1)"
        inode_lnk="$(ls -di "$(readlink "${HOME}/${file}")" | cut -d ' ' -f 1)"
        if [ "${inode_org}" -eq "${inode_lnk}" ]; then
            continue
        fi
    fi
    if ! (set -x; ln -s "${PARENT}/${file}" "${HOME}/" "${@}"); then
        ls -ld "${HOME}/${file}"
        rc=1
    fi
done
IFS="${IFSORG}"

exit "${rc}"
