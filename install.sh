#!/bin/sh

PARENT="$(d=${0%/*}/; [ "_$d" = "_$0/" ] && d='./'; cd "$d"; pwd)"

find "${PARENT}/" -mindepth 1 -maxdepth 1 -name '.*' -not -name '.git' |
sed 's#^.*/##' |
while IFS= read -r file; do
    if ! (set -x; ln -s "${PARENT}/${file}" "${HOME}/" "${@}"); then
        ls -ld "${HOME}/${file}"
    fi
done
