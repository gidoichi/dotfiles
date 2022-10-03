#!/bin/sh

# alias cp='cp -i'

# alias grep='grep --color=auto'

if type powershell.exe >/dev/null 2>&1 &&
   type dart           >/dev/null 2>&1 &&
   file "$(which dart)" | grep CRLF >/dev/null; then
    alias dart='powershell.exe -Command dart'
fi

alias emacs=editor-wrapper

if type powershell.exe >/dev/null 2>&1 &&
   type flutter        >/dev/null 2>&1 &&
   file "$(which flutter)" | grep CRLF >/dev/null; then
    alias flutter='powershell.exe -Command flutter'
fi

if type javac >/dev/null 2>&1; then
    alias javac='javac -encoding UTF-8'
fi

if type javac.exe >/dev/null 2>&1; then
    alias javac.exe='javac.exe -encoding UTF-8'
fi

if type kubectl >/dev/null 2>&1; then
    alias k='kubectl'
fi

# alias ls='ls --color=auto'

# alias lsib="ls --ignore-backup"

# alias mv='mv -i'

if type py >/dev/null 2>&1; then
    alias py2='py -2'
    alias py3='py -3'
fi

if [ -e /usr/local/share/java/plantuml.jar ]; then
    alias plantuml="java -jar /usr/local/share/java/plantuml.jar"
fi

if type R >/dev/null 2>&1; then
    alias R='R -q --no-save'
fi

# alias rm='rm -i'

# > If the last character of the alias value is a blank, then the
# > next command word following the alias is also checked for alias
# > expansion.
# (https://www.man7.org/linux/man-pages/man1/bash.1.html)
alias watch='watch '

# alias wgetp='wget -P ~/Downloads/'
