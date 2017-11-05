#!/bin/zsh

LOCK_BG=$HOME/pictures/lockscreen.png

if [[ "$1" == "--set" ]]; then
   IMAGES=($WALLPAPER_FOLDER/*)
   convert ${IMAGES[RANDOM % ${#IMAGES[@]} + 1]} $LOCK_BG
else
   i3lock -n -i $LOCK_BG
fi
