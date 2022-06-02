#!/usr/bin/env zsh

if [ -z "$ZSH_NAME" ]; then return 1; fi

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
