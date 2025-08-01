#!/bin/sh

if type zprezto-update >/dev/null 2>&1; then
    _show_return='✘ '
    if zstyle -t ':prezto:module:prompt' show-return-val yes; then
        _show_return="${_show_return}%? "
    fi
    export RPROMPT="%(?:: %F{1}${_show_return}%f)"
fi

if ! alias cp >/dev/null 2>&1; then
    alias cp='cp -i'
fi

# asdf
_file=''
if type brew >/dev/null 2>&1; then
    _file="$(brew --prefix asdf)/asdf.sh"
fi
if [ -f "${_file}" ]; then
    . "${_file}"
fi

if type basher >/dev/null 2>&1; then
    case "${CURRENT_SHELL}" in
        bash) eval "$(basher init - bash)" ;;
        zsh)  eval "$(basher init - zsh )" ;;
    esac
fi

_file='/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe'
if type "$file" >/dev/null 2>&1; then
    export BROWSER="$file"
fi

if type cf >/dev/null 2>&1; then
    cf() {
        # $ cf (help|h|--help|-h)
        if { [ "$1" = 'help' ] || [ "$1" = 'h' ] || [ "$1" = '--help' ] || [ "$1" = '-h' ]; } && [ "${#}" -eq 1 ]; then
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
        if { [ "${1}" = 'target' ] || [ "${1}" = 't' ]; } && [ "${2}" = '-o' ] && [ "${#}" -eq 2 ]; then
            _org=$(cf orgs |
                      awk 'f{print} !f&&$0!="name"{print>"/dev/stderr"} !f&&$0=="name"{f=!f}' |
                      "${ONELINE_SELECTOR}")
            if [ "${_org}" = '' ]; then
                return 1
            fi
            cf target -o "${_org}"
            return
        fi

        # $ cf (target|t) -s
        if { [ "${1}" = 'target' ] || [ "${1}" = 't' ]; } && [ "${2}" = '-s' ] && [ "${#}" -eq 2 ]; then
            _space=$(cf spaces |
                        awk 'f{print} !f&&$0!="name"{print>"/dev/stderr"} !f&&$0=="name"{f=!f}' |
                        "${ONELINE_SELECTOR}")
            if [ "${_space}" = '' ]; then
                return 1
            fi
            cf target -s "${_space}"
            return
        fi

        # call original command
        command cf "$@"
    }
fi


if type powershell.exe dart >/dev/null 2>&1 &&
   file "$(which dart)" | grep -q CRLF; then
    alias dart='powershell.exe -Command dart'
fi

if type direnv >/dev/null 2>&1; then
    case "${CURRENT_SHELL}" in
        bash) eval "$(direnv hook bash)" ;;
        zsh)  eval "$(direnv hook zsh )" ;;
    esac
fi

# emacs
if type emacs >/dev/null 2>&1; then
    alias emacs=editor-wrapper
    export EDITOR=emacs
    if [ -n "${INSIDE_EMACS}" ]; then
        export EDITOR=emacsclient
    fi
    export VISUAL="${EDITOR}"
fi
if [ -n "${INSIDE_EMACS}" ]; then
    case "${CURRENT_SHELL}" in
        bash)
            _file=$(emacsclient -e '(expand-file-name
                                      "straight/repos/emacs-libvterm/etc/emacs-vterm-bash.sh"
                                      doom-local-dir)' |
                        sed -e 's/^"//' -e 's/"$//')
            if [ -e "${_file}" ]; then
                . "${_file}"
            fi
            ;;
        zsh)
            _file=$(emacsclient -e '(expand-file-name
                                      "straight/repos/emacs-libvterm/etc/emacs-vterm-zsh.sh"
                                      doom-local-dir)' |
                        sed -e 's/^"//' -e 's/"$//')
            if [ -e "${_file}" ]; then
                # workaround: using add-zsh-hook prevents latter registration
                eval "$(cat "${_file}" | grep -v add-zsh-hook)"
            fi
            ;;
    esac
fi

if type powershell.exe flutter >/dev/null 2>&1 &&
   file "$(which flutter)" | grep -q CRLF; then
    alias flutter='powershell.exe -Command flutter'
fi

# fzf
case "${CURRENT_SHELL}" in
    bash)
        if fzf --bash >/dev/null 2>&1; then
            # introduced in https://github.com/junegunn/fzf/releases/tag/0.48.0
            eval "$(fzf --bash)"
        elif [ -d /usr/share/doc/fzf/examples ]; then
            . /usr/share/doc/fzf/examples/key-bindings.bash
        elif [ -f "${HOME}/.fzf.bash" ]; then
            . "${HOME}/.fzf.bash"
        fi
        ;;
    zsh)
        if fzf --zsh >/dev/null 2>&1; then
            # introduced in https://github.com/junegunn/fzf/releases/tag/0.48.0
            eval "$(fzf --zsh)"
        elif [ -d /usr/share/doc/fzf/examples ]; then
            . /usr/share/doc/fzf/examples/key-bindings.zsh
            . /usr/share/doc/fzf/examples/completion.zsh
        elif [ -f "${HOME}/.fzf.zsh" ]; then
            . "${HOME}/.fzf.zsh"
        fi
        ;;
esac
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --exit-0'

if type ghq >/dev/null 2>&1; then
    ghq() {

        # $ ghq
        if [ $# -eq 0 ]; then
            ghq cd
            return
        fi

        # $ ghq (help|h|--help|-h)
        if [ "$1" = 'help' ] || [ "$1" = 'h' ] || [ "$1" = '--help' ] || [ "$1" = '-h' ]; then
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
        if [ "$1" = "cd" ] && [ $# -eq 1 ]; then
            _repo=$(ghq list | ${ONELINE_SELECTOR})
            ghq cd "${_repo}"
            return
        fi

        # $ ghq cd <repository>
        if [ "$1" = 'cd' ] && [ $# -eq 2 ]; then
            _target="$2"
            _repo=$(ghq list | awk '$0=="'"${_target}"'"')
            _root=$(ghq root)
            if [ -z "${_repo}" ]; then
                return 1
            fi
            cd "${_root}/${_repo}"
            return
        fi

        # $ ghq (rm|remove)
        if { [ "$1" = 'rm' ] || [ "$1" = 'remove' ]; } && [ $# -eq 1 ]; then
            _repo=$(ghq list | ${ONELINE_SELECTOR})
            if [ -z "${_repo}" ]; then
                return 1
            fi
            ghq rm "${_repo}"
            return
        fi

        # $ ghq (rm|remove) <repository>
        if { [ "$1" = "rm" ] || [ "$1" = "remove" ]; } && [ $# -eq 2 ]; then
            _target="$2"
            _repo=$(ghq list | awk '$0=="'"${_target}"'"')
            _root=$(ghq root)
            if [ -z "${_repo}" ]; then
                return 1
            fi
            if ! [ -d "${_root}/${_repo}" ]; then
                echo "no such repository: ${_target}" >&2
                return 1
            fi
            printf "remove: ${_repo}: ok? (y/N): "; read yn
            case "$yn" in
                [yY]*) ;;
                *) return ;;
            esac
            rm -rf "${_root}/${_repo}"
            mkdir "${_root}/${_repo}"
            while rmdir "${_root}/${_repo}" >/dev/null 2>&1; do
                echo "remove: ${_root}/${_repo}" >&2
                _repo=$(dirname "${_repo}")
                if [ "${_repo}" = '.' ]; then
                    break
                fi
            done
            return
        fi

        # $ ghq (rm|remove) <repository> <...repository>
        if { [ "$1" = 'rm' ] || [ "$1" = 'remove' ]; } && [ $# -ge 3 ]; then
            _repo="$2"
            ghq rm "${_repo}"
            shift 2
            ghq rm "$@"
            return
        fi

        # call original command
        command ghq "$@"
    }
fi

if ! alias git >/dev/null 2>&1; then
    alias git='PAGER= git'
fi

if ! alias grep >/dev/null 2>&1; then
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
if [ -n "${GIT_CREDENTIAL_KEEPASSXC}" ]; then
    :
elif type git-credential-keepassxc.exe >/dev/null 2>&1; then
    export GIT_CREDENTIAL_KEEPASSXC='git-credential-keepassxc.exe'
elif type git-credential-keepassxc >/dev/null 2>&1; then
    export GIT_CREDENTIAL_KEEPASSXC='git-credential-keepassxc'
fi
if [ -n "${GIT_CREDENTIAL_KEEPASSXC}" ]; then
    keepassxc_client() {
        (
            set -eu
            exit_trap() {
                set -- ${1:-} $?  # $? is set as $1 if no argument given
                trap '' EXIT HUP INT QUIT PIPE ALRM TERM
                [ -d "${Tmp:-}" ] && rm -rf "${Tmp%/*}/_${Tmp##*/_}"
                trap -  EXIT HUP INT QUIT PIPE ALRM TERM
                exit $1
            }
            trap 'exit_trap' EXIT HUP INT QUIT PIPE ALRM TERM
            Tmp=$(mktemp -d -t "_${0##*/}.$$.XXXXXXXXXXX") || error_exit 1 'Failed to mktemp'

            KEEPASSXC_CLIENT_RETRY=${KEEPASSXC_CLIENT_RETRY:-5}
            i=0
            while ! cred=$(printf 'url=%s\nusername=%s\n' "${1}" "$(hostname)" |
                               "${GIT_CREDENTIAL_KEEPASSXC}" --unlock 0 get 2> "${Tmp}/stderr"); do
                i=$((i+1))
                if ! grep -q -e 'Failed to connect to ' -e 'Failed to locate socket' "${Tmp}/stderr"; then
                    cat "${Tmp}/stderr" 1>&2
                    return 1
                fi
                printf '[%d/%d]: %s\n' "${i}" "${KEEPASSXC_CLIENT_RETRY}" "$(cat "${Tmp}/stderr")" >&2
                if [ "${i}" -ge "${KEEPASSXC_CLIENT_RETRY}" ]; then
                    return 1
                fi
                if [ "${i}" -eq 1 ]; then
                    : "${KEEPASSXC_GUI}"
                    nohup "${KEEPASSXC_GUI}" >/dev/null 2>&1 &
                fi
                rm -rf "${Tmp}/stderr"
                sleep 1
            done
            printf '%s' "${cred}" | sed -n 's/^password=//p'
        )
    }
fi

if type kubectl >/dev/null 2>&1; then
    if type colordiff >/dev/null 2>&1; then
        export KUBECTL_EXTERNAL_DIFF='colordiff --new-file --unified'
    else
        export KUBECTL_EXTERNAL_DIFF='diff --color --new-file --unified'
    fi
    alias k=kubectl
    kubectl() {
        if type kubecolor >/dev/null 2>&1; then
            subcmd="$1"
            case "$subcmd" in
                diff) ;;
                *)    kubecolor "$@"; return
            esac
        fi

        if type kubectl-colorize_applied >/dev/null 2>&1; then
            subcmd="$1"
            case "$subcmd" in
                apply|create)
                    command kubectl "$@" | kubectl colorize-applied
                    return
            esac
        fi

        command kubectl "$@"
    }
fi

_file=''
if type brew >/dev/null 2>&1; then
    case "${CURRENT_SHELL}" in
        bash|zsh)
            _file="$(brew --prefix kube-ps1)"
            _file="${_file:+${_file}/share/kube-ps1.sh}"
            ;;
    esac
fi
if [ -e "${_file}" ]; then
    . "${_file}"
    kubeoff
fi
if type kube_ps1 >/dev/null 2>&1; then
    case "${CURRENT_SHELL}" in
        zsh)
            export PROMPT="$(printf '%s' "${PROMPT}" | awk '{if($0!=""&&f==0){print $0,"$(kube_ps1)";f=1}else{print}}')"
            ;;
    esac
    kube_ps1_cluster_function() { (
        printf '%s' "${1}"
        if type asdf >/dev/null 2>&1; then
            asdf-match --log=notice kubectl
        fi >&2
    ) }
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

# ls
if ! alias ls >/dev/null 2>&1; then
    alias ls='ls --color=auto'
fi
if ! alias ll >/dev/null 2>&1; then
    alias ll='ls -lh'
fi
if ! alias la >/dev/null 2>&1; then
    alias la='ll -A'
fi

if ! alias mv >/dev/null 2>&1; then
    alias mv='mv -i'
fi

export PAGER='editor-wrapper -e emacs-pager -'
export DOOMPAGER="$PAGER"

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

if ! alias rm >/dev/null 2>&1; then
    alias rm='rm -i'
fi

if type screen >/dev/null 2>&1; then
    export SCREENDIR="${HOME}/.screen"
fi

if type trash-put >/dev/null 2>&1 && [ ! -e "$HOME/.local/share/Trash" ]; then
    mkdir -p "$HOME/.local/share/Trash"
fi

# ssh
export SSH_ASKPASS='keepassxc-ssh-askpass'
export SSH_ASKPASS_REQUIRE='force'

alias watch='watch --color '

alias wgetp='wget -P ~/Downloads/'
