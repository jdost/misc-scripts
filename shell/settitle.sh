#!/bin/sh

TITLE=""
if [[ $# == 0 ]]; then
   TITLE=$(tty | cut -d/ -f 3-)
else
   TITLE=$*
fi

if [[ -z "$TITLE" ]]; then
   echo "Something went wrong..."
   exit 1
elif [[ -z "$TMUX" ]]; then
   echo -ne "\033]0;$TITLE\007"
else
   printf "\033k$TITLE\033\\"
fi
