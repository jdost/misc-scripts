#!/bin/zsh

WP_FOLDER=$HOME/.wallpapers
CURRENT=$WP_FOLDER/Current
COLOR_GEN=$HOME/.scripts/color_gen.py

if [ -f $CURRENT ]; then
   rm $CURRENT
fi

WP_FILES=($WP_FOLDER/*)
RANDOM_WP="${WP_FILES[RANDOM % ${#WP_FILES[@]}]}"

ln -s "$RANDOM_WP" $CURRENT

# generate/link the new colorscheme
$HOME/.local/virtualenvs/playground/bin/python2 $COLOR_GEN
xrdb -merge $XDG_CONFIG_HOME/X11/Xresources

feh --bg-scale --no-fehbg $CURRENT
