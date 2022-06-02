#!/bin/sh

if ! type cf >/dev/null 2>&1; then
    return 1
fi

cf() {

    # $ cf (help|h|--help|-h)
    if [ "$1" = 'help' -o "$1" = 'h' -o "$1" = '--help' -o "$1" = '-h' ] &&
           [ "${#}" -eq 1 ]; then
        command cf --help 2>&1
        cat <<-EOF

	EXTENDED USAGE (Override above):
	   cf (target|t) -o          Select and set one org
	   cf (target|t) -s          Select and set one org
	   cf help, h, --help, -h    Show extended help
	EOF
        return
    fi

    # $ cf (target|t) -o
    if [ "${1}" = 'target' -o "${1}" = 't' ] && [ "${2}" = '-o' ] &&
           [ "${#}" -eq 2 ]; then
        org=$(cf orgs |
                  awk 'f{print} !f&&$0!="name"{print>"/dev/stderr"} !f&&$0=="name"{f=!f}' |
                  "${ONELINE_SELECTOR}")
        if [ "${org}" = '' ]; then
            return 1
        fi
        cf target -o "${org}"
        return
    fi

    # $ cf (target|t) -s
    if [ "${1}" = 'target' -o "${1}" = 't' ] && [ "${2}" = '-s' ] &&
           [ "${#}" -eq 2 ]; then
        space=$(cf spaces |
                    awk 'f{print} !f&&$0!="name"{print>"/dev/stderr"} !f&&$0=="name"{f=!f}' |
                    "${ONELINE_SELECTOR}")
        if [ "${space}" = '' ]; then
            return 1
        fi
        cf target -s "${space}"
        return
    fi

    # call original command
    command cf "$@"
}
