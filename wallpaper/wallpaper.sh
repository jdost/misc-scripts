#!/bin/zsh

if [ -z "$WALLPAPER_FOLDER" ]; then
   WALLPAPER_FOLDER=$HOME/.wallpapers
fi

if [ ! -d "$WALLPAPER_FOLDER" ]; then
   mkdir -p "$WALLPAPER_FOLDER"
fi

if [ $# -gt 0 ]; then
   if [ "$1" = "update" ]; then
      $(dirname $(realpath $0))/imgur_update.py
      exit 0
   elif [ "$1" = "count" ]; then
      echo "Wallpaper Count: $(ls $WALLPAPER_FOLDER | grep jpg | wc -l)"
      exit 0
   fi
fi

CURRENT=$WALLPAPER_FOLDER/Current

if [ -f $CURRENT ]; then
   rm $CURRENT
fi

WP_FILES=($WALLPAPER_FOLDER/*)
RANDOM_WP="${WP_FILES[RANDOM % ${#WP_FILES[@]} + 1]}"

ln -s "$RANDOM_WP" $CURRENT

# generate/link the new colorscheme
#COLOR_GEN=$HOME/.scripts/color_gen.py
#$HOME/.local/virtualenvs/playground/bin/python2 $COLOR_GEN "$RANDOM_WP"
#xrdb -merge $XDG_CONFIG_HOME/X11/Xresources

feh --bg-scale --no-fehbg $CURRENT
