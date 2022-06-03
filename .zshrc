#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# external source
source "$HOME/.shell/shrc"; source "$HOME/.shell/custom.sh"

# completions
if type kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
fi

# fzf
if [ -d /usr/share/doc/fzf/examples ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
else
    source "$HOME/.fzf.zsh"
fi
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'
