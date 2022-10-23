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

# environment variable
CURRENT_SHELL=zsh

# external source
. "$HOME/.shell/shrc"

# completions
if type kubectl >/dev/null; then
    source <(kubectl completion zsh)
fi
