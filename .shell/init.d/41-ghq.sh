#!/bin/sh

if ! type ghq >/dev/null 2>&1; then
    return 1
fi

ghq() {

    # $ ghq
    if [ $# -eq 0 ]; then
        ghq cd
        return
    fi

    # $ ghq (help|h|--help|-h)
    if [ "$1" = 'help' -o "$1" = 'h' -o "$1" = '--help' -o "$1" = '-h' ]; then
        command ghq --help 2>&1
        cat <<-EOF

	EXTENDED USAGE (Override above):
	   ghq             Same as "ghq cd"
	   ghq cd          Select and change directory to one repository
	   ghq cd <repo>   Change directory to <repo>
	   ghq rm, remove  Select and remove one repository
	   ghq rm, remove <repos...>  Remove one or more repositories
	   ghq help, h, --help, -h    Show extended help
	EOF
        return
    fi

    # $ ghq cd
    if [ "$1" = "cd" ] &&
           [ $# -eq 1 ]; then
        repo=$(ghq list | ${ONELINE_SELECTOR})
        ghq cd "${repo}"
        return
    fi

    # $ ghq cd <repository>
    if [ "$1" = 'cd' ] &&
           [ $# -eq 2 ]; then
        target="$2"
        repo=$(ghq list | awk '$0=="'"$target"'"')
        root=$(ghq root)
        if [ -z "${repo}" ]; then
            return 1
        fi
        cd "${root}/${repo}"
        return
    fi

    # $ ghq (rm|remove)
    if [ "$1" = 'rm' -o "$1" = 'remove' ] &&
           [ $# -eq 1 ]; then
        repo=$(ghq list | ${ONELINE_SELECTOR})
        if [ -z "${repo}" ]; then
            return 1
        fi
        ghq rm "${repo}"
        return
    fi

    # $ ghq (rm|remove) <repository>
    if [ "$1" = "rm" -o "$1" = "remove" ] &&
           [ $# -eq 2 ]; then
        target="$2"
        repo=$(ghq list | awk '$0=="'"$target"'"')
        root=$(ghq root)
        if [ -z "${repo}" ]; then
            return 1
        fi
        if ! [ -d "${root}/${repo}" ]; then
            echo "no such repository: ${target}" >&2
            return 1
        fi
        rm -rf "${root}/${repo}"
        mkdir "${root}/${repo}"
        echo "remove: ${root}/${repo}" >&2
        while rmdir "${root}/${repo}" >/dev/null 2>&1; do
            repo=$(dirname "${repo}")
            if [ "${repo}" = '.' ]; then
                break
            fi
        done
        return
    fi

    # $ ghq (rm|remove) <repository> <...repository>
    if [ "$1" = 'rm' -o "$1" = 'remove' ] &&
           [ $# -ge 3 ]; then
        repo="$2"
        ghq rm "${repo}"
        shift 2
        ghq rm "$@"
        return
    fi

    # call original command
    command ghq "$@"
}
