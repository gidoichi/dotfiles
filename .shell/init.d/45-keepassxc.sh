#!/bin/sh

if type git-credential-keepassxc.exe >/dev/null; then
    git_credential_keepassxc() {
        if ! cred=$(printf "url=%s\nusername=%s\n" "${1}" "${HOST}" |
                        git-credential-keepassxc.exe --unlock 0 get --json)
        then
            return 1
        fi
        printf '%s' "${cred}" | jq -r '.password'
    }
elif type git-credential-keepassxc >/dev/null; then 
    git_credential_keepassxc() {
        if ! cred=$(printf "url=%s\nusername=%s\n" "${1}" "${HOST}" |
                        git-credential-keepassxc --unlock 0 get --json)
        then
            return 1
        fi
        printf '%s' "${cred}" | jq -r '.password'
    }
fi


