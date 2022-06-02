#!/bin/sh

# aliases
if ! alias date >/dev/null 2>&1 &&
   type gdate   >/dev/null 2>&1; then
    alias date='gdate'
fi
if ! alias ls >/dev/null 2>&1 &&
   type gls   >/dev/null 2>&1; then
    alias ls='gls'
fi
if ! alias timeout >/dev/null 2>&1 &&
   type gtimeout   >/dev/null 2>&1; then
    alias timeout='gtimeout'
fi
