#!/bin/zsh

if [ -z "$WALLPAPER_FOLDER" ]; then
   WALLPAPER_FOLDER=$HOME/.wallpapers
fi

if [ ! -d "$WALLPAPER_FOLDER" ]; then
   mkdir -p "$WALLPAPER_FOLDER"
fi

case "$1" in
   "-h"|"--help")
      echo "wallpaper [action]"
      echo "  update | up  -- Pull down latest wallpapers"
      echo "  upload | add -- Put in URLs of wallpapers to get, end with Ctrl-D"
      echo "  count  | c   -- Prints number of wallpapers on machine"
      echo "  --help | -h  -- This help menu"
      echo "  [Nothing]    -- manually updates current wallpaper"
      exit 0
      ;;
   "update"|"up")
      $(dirname $(realpath $0))/grab_wallpapers.py
      exit 0
      ;;
   "upload"|"add")
      $(dirname $(realpath $0))/upload.sh
      exit 0
      ;;
   "count"|"c")
      echo "Wallpaper Count: $(ls $WALLPAPER_FOLDER | grep jpg | wc -l)"
      exit 0
      ;;
   "cron")
      if [ -z "$(crontab -l | grep WALLPAPER_FOLDER)" ]; then
         echo "Cronjob not set up..."
         echo "  Edit your crontab with \`crontab -e\`"
         echo "  And use this command: \"export DISPLAY=:0.0; export WALLPAPER_FOLDER=$WALLPAPER_FOLDER; $0\""
      fi

      exit 0
      ;;
esac

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

feh --bg-fill --no-fehbg $CURRENT
