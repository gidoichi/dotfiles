#!/bin/sh

case "${CURRENT_SHELL}" in
    bash|zsh) ;;
    *) return 1;;
esac

if type zprezto-update >/dev/null 2>&1; then
    prompt steeef
fi

if alias cp >/dev/null 2>&1; then
    alias cp='cp -i'
fi

# asdf
file="$(brew --prefix asdf)/asdf.sh"
if [ -f "${file}" ]; then
    . "${file}"
fi

if type basher >/dev/null 2>&1; then
    eval "$(basher init - "${CURRENT_SHELL}")"
fi

if type cf >/dev/null 2>&1; then
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
fi


if type powershell.exe dart >/dev/null 2>&1 &&
   file "$(which dart)" | grep CRLF >/dev/null; then
    alias dart='powershell.exe -Command dart'
fi

if type direnv >/dev/null 2>&1; then
    eval "$(direnv hook "${CURRENT_SHELL}")"
fi

if type emacs >/dev/null 2>&1; then
    alias emacs=editor-wrapper
    export EDITOR=emacs
    if [ -n "${INSIDE_EMACS}" ]; then
        export EDITOR=emacsclient
    fi
    export VISUAL="${EDITOR}"
fi

if type powershell.exe flutter >/dev/null 2>&1 &&
   file "$(which flutter)" | grep CRLF >/dev/null; then
    alias flutter='powershell.exe -Command flutter'
fi

# fzf
if [ -d /usr/share/doc/fzf/examples ]; then
    if [ "${CURRENT_SHELL}" = 'zsh' ]; then
        . /usr/share/doc/fzf/examples/key-bindings.zsh
        . /usr/share/doc/fzf/examples/completion.zsh
    elif [ "${CURRENT_SHELL}" = 'bash' ]; then
        . /usr/share/doc/fzf/examples/key-bindings.bash
    fi
else
    if [ "${CURRENT_SHELL}" = 'zsh' ]; then
        . "$HOME/.fzf.zsh"
    fi
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

if type ghq >/dev/null 2>&1; then
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
            while rmdir "${root}/${repo}" >/dev/null 2>&1; do
                echo "remove: ${root}/${repo}" >&2
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
fi

if alias grep >/dev/null 2>&1; then
    alias grep='grep --color=auto'
fi

# java
if type javac >/dev/null 2>&1; then
    alias javac='javac -encoding UTF-8'
fi
if type javac.exe >/dev/null 2>&1; then
    alias javac.exe='javac.exe -encoding UTF-8'
fi

# keepassxc
if type git-credential-keepassxc.exe >/dev/null 2>&1; then
    GIT_CREDENTIAL_KEEPASSXC='git-credential-keepassxc.exe'
elif type git-credential-keepassxc >/dev/null 2>&1; then 
    GIT_CREDENTIAL_KEEPASSXC='git-credential-keepassxc'
fi
if [ -n "${GIT_CREDENTIAL_KEEPASSXC}" ]; then
    git_credential_keepassxc() {
        if ! cred=$(printf "url=%s\nusername=%s\n" "${1}" "${HOST}" |
                        "${GIT_CREDENTIAL_KEEPASSXC}" --unlock 0 get --json)
        then
            return 1
        fi
        printf '%s' "${cred}" | jq -r '.password'
    }
fi

if type kubectl >/dev/null 2>&1; then
    alias k='kubectl'
fi

target="$(brew --prefix kube-ps1)"
target="${target:+${target}/share/kube-ps1.sh}"
if [ -n "${target}" ]; then
    . "$(brew --prefix kube-ps1)/share/kube-ps1.sh"
    kubeoff
fi
if type kube_ps1 >/dev/null 2>&1; then
    if [ "${CURRENT_SHELL}" = 'zsh' ]; then 
        export PROMPT="$(printf '%s' "${PROMPT}" | awk '{if($0!=""&&f==0){print $0,"$(kube_ps1)";f=1}else{print}}')"
    fi
    kube_ps1_cluster_function() {
        printf '%s' "${1}"
        if type asdf >/dev/null 2>&1; then
            set -eu
            versions="$(set -x; kubectl version -o json)"
            client="$(printf '%s' "${versions}" | jq -re '.clientVersion.gitVersion')"
            server="$(printf '%s' "${versions}" | jq -re '.serverVersion.gitVersion')"
            [ "${server}" = "${client}" ] && return
            version="$(printf '%s' "${server}" | sed 's/^v//')"
            (set -x; asdf plugin add kubectl) || true
            (set -x; asdf install kubectl "${version}")
            (set -x; asdf global  kubectl "${version}")
        fi >&2
    }
    export KUBE_PS1_CLUSTER_FUNCTION=kube_ps1_cluster_function
fi

# line-selector
if type fzf >/dev/null 2>&1; then
    export LINE_SELECTOR=fzf
elif type lnum-select >/dev/null 2>&1; then
    export LINE_SELECTOR=lnum-select
fi
export ONELINE_SELECTOR=1line-select

# locale
export LC_COLLATE=ja_JP.UTF-8

if alias ls >/dev/null 2>&1; then
    alias ls='ls --color=auto'
fi

if alias mv >/dev/null 2>&1; then
    alias mv='mv -i'
fi

if [ -e /usr/local/share/java/plantuml.jar ]; then
    alias plantuml='java -jar /usr/local/share/java/plantuml.jar'
fi

# python
if type py >/dev/null 2>&1; then
    alias py2='py -2'
    alias py3='py -3'
fi

if type R >/dev/null 2>&1; then
    alias R='R -q --no-save'
fi

if alias rm >/dev/null 2>&1; then
    alias rm='rm -i'
fi

if type screen >/dev/null 2>&1; then
    export SCREENDIR="${HOME}/.screen"
fi

if type trash-put >/dev/null 2>&1 && [ ! -e "$HOME/.local/share/Trash" ]; then
    mkdir -p "$HOME/.local/share/Trash"
fi

alias watch='watch '

alias wgetp='wget -P ~/Downloads/'