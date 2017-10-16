#!/bin/zsh

LS_BIN=/usr/bin/ls

LATEST=0
TERM=0

if [ -z "$WALLPAPER_FOLDER" ]; then
   WALLPAPER_FOLDER=$HOME/.wallpapers
fi

if [ ! -d "$WALLPAPER_FOLDER" ]; then
   mkdir -p "$WALLPAPER_FOLDER"
elif [ -h "$WALLPAPER_FOLDER" ]; then
   WALLPAPER_FOLDER=$(readlink -f "$WALLPAPER_FOLDER")
fi

case "$1" in
   "-h"|"--help")
      echo "wallpaper [action]"
      echo "  update | up  -- Pull down latest wallpapers"
      echo "  upload | add -- Put in URLs of wallpapers to get, end with Ctrl-D"
      echo "  count  | c   -- Prints number of wallpapers on machine"
      echo "  latest | l   -- Updates current wallpaper from latest batch"
      echo "  --help | -h  -- This help menu"
      echo "  color  | t   -- Update terminal colors"
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
      echo "Wallpaper Count: $($LS_BIN $WALLPAPER_FOLDER | grep jpg | wc -l)"
      exit 0
      ;;
   "cron")
      if [ -z "$(crontab -l | grep WALLPAPER_FOLDER)" ]; then
         echo "Cronjob not set up..."
         echo "  Edit your crontab with \`crontab -e\`"
         echo "  And use this command: \"env DISPLAY=:0.0 WALLPAPER_FOLDER=$WALLPAPER_FOLDER $0\""
      fi

      exit 0
      ;;
   "latest"|"l")
      LATEST=1
      ;;
   "color"|"t")
      TERM=1
      ;;
esac

CURRENT=$WALLPAPER_FOLDER/Current

if [ -h $CURRENT ]; then
   /usr/bin/rm $CURRENT
fi

if [ $LATEST = "1" ]; then
   LATEST_TS=$($LS_BIN -lt $WALLPAPER_FOLDER | egrep -v "Current|total" | head -1 | awk '{ print $6 " " $7 }')
   WP_FILES_RAW=$($LS_BIN -lt $WALLPAPER_FOLDER | grep -v "Current|total" | awk '{ print $6 " " $7 " " $9 }' | egrep $LATEST_TS | awk '{ print $3 }')
   WP_FILES=(${=WP_FILES_RAW})
else
   WP_FILES=($WALLPAPER_FOLDER/*)
fi
RANDOM_WP="${WP_FILES[RANDOM % ${#WP_FILES[@]} + 1]}"

/usr/bin/ln -s "$RANDOM_WP" $CURRENT

if [ $TERM = "1" ]; then
   COLOR_GEN=$(dirname $(realpath $0))/color_gen.py
   $HOME/.local/virtualenvs/wallpaper/bin/python2 $COLOR_GEN "$RANDOM_WP"
   xrdb -merge $XDG_CONFIG_HOME/X11/Xresources
   $(dirname $(realpath $0))/load_colors.sh
fi

/usr/bin/feh --bg-fill --no-fehbg $CURRENT
