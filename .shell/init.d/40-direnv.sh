#!/bin/sh

if ! type direnv >/dev/null 2>&1; then return 1; fi

shell=$(ps -p $$ | tail -n 1 | awk '{print $NF}')
eval "$(direnv hook $shell)"
