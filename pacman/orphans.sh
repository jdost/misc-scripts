#!/bin/sh

if [[ ! -n $(pacman -Qdt) ]]; then
   echo "No orphans to remove."
else
   sudo pacman -Rs $(pacman -Qdtq)
fi
