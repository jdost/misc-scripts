#!/bin/zsh

set -euo pipefail

# If running headless, grab the first available display, this is a bit naive but
#  allows for things like cron tasks to still set wallpapers
if [[ -z "${DISPLAY:-}" ]]; then
   export DISPLAY=":$(
      ls /tmp/.X11-unix/* \
         | head -n1 \
         | set 's#/tmp/.X11-unix/X##'
   )"
fi

WALLPAPER_FOLDER="${WALLPAPER_FOLDER:-$HOME/.wallpapers}"
[[ ! -d "$WALLPAPER_FOLDER" ]] && mkdir -p "$WALLPAPER_FOLDER"
if [[ -h "$WALLPAPER_FOLDER" ]]; then
   WALLPAPER_FOLDER=$(readlink -f "$WALLPAPER_FOLDER")
fi

help() {
   cat << HELP
wallpaper [action]
  --help | -h  -- This help menu
  update | up  -- Pull down latest wallpapers
  upload | add -- Put in URLs of wallpapers to get, end with Ctrl-D
  count  | c   -- Prints number of wallpapers on machine
  latest | l   -- Updates current wallpaper from latest batch
  [Nothing]    -- Updates current wallpaper from random selection in whole collection
HELP
}

case "${1:-}" in
   "-h"|"--help")
      help
      exit 0
      ;;
   "update"|"up")
      exec $(dirname $(realpath $0))/grab_wallpapers.py ;;
   "upload"|"add")
      exec $(dirname $(realpath $0))/upload.sh ;;
   "count"|"c")
      echo "Wallpaper Count: $(find $WALLPAPER_FOLDER/ -type f | wc -l)"
      exit 0
      ;;
   "latest"|"l")
      latest=1
      ;;
esac

CURRENT=$WALLPAPER_FOLDER/Current
[[ -h $CURRENT ]] && rm $CURRENT

if [ "${latest:-0}" = "1" ]; then
   # Get the files that were created in the latest batch of retrievals
   #
   # `find` - find files in the wallpaper folder created after (inclusive) a certain
   #     date, format expected is `YYYY-MM-DD`
   #   `stat` - output the human readable creation time for the file
   #     `ls -t` - list contents sorted by time created
   #     `head -1` - we only want the first result, i.e. the newest file
   #   `awk` - only print out the first part, which is just the date (drops the
   #        timestamp)
   WP_FILES_RAW=$(
      find $WALLPAPER_FOLDER -type f -newerct $(
         stat -c %y $WALLPAPER_FOLDER/$(
            \ls -t $WALLPAPER_FOLDER \
               | head -1
            ) | awk '{ print $1 }'
         )
      )
   # Transform the listing into a native array
   WP_FILES=(${=WP_FILES_RAW})
else
   WP_FILES=($WALLPAPER_FOLDER/*)
fi

ln -s "${WP_FILES[RANDOM % ${#WP_FILES[@]} + 1]}" "$CURRENT"
feh --bg-fill --no-fehbg "$CURRENT"
