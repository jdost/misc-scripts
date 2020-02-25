#!/bin/sh

set -euo pipefail

if [[ -z "$XAUTHORITY" ]]; then
   # If there is no default XAUTHORITY, we need to determine the value
   #  programmatically, this is often the case when this is triggered via something
   #  like an acpi event or uevent
   #
   # `ps` - List the running root Xorg process, which includes auth file
   #  `sed` - Trim all *but* the auth file listing
   export XAUTHORITY=$(
      ps -C Xorg -f --no-header \
         | sed -n 's/.*-auth //;s/ -[^ ].*//; p'
   )
fi
if [[ -z "${DISPLAY:-}" ]]; then
   # If there is no default DISPLAY, we need to determine the value programmatically
   #
   # `ls` - list all files in the X11 tmp directory, each corresponds to an x display
   #  `sed` - Trim off the prefix and get just the display number
   export DISPLAY=":$(
      \ls /tmp/.X11-unix/* \
         | head -n1 \
         | sed 's#/tmp/.X11-unix/X##'
   )"
fi

BUILTIN_DISPLAY="eDP-1"  # Hardcoded display considered the internal
EXTERNAL_DISPLAY=""
# List all xrandr options and filter out those that are "connected"
CONNECTED_DISPLAYS=$(
   xrandr \
      | grep " connected " \
      | cut -d' ' -f1
)
ACTIVE_DISPLAYS=$(
   xrandr --listactivemonitors \
      | tail -n +2 \
      | awk '{ print $NF }'
)
LID_STATE="$(
   cat /proc/acpi/button/lid/LID0/state \
      | cut -d':' -f2 \
      | sed -e 's/[ \t]*//'
)"
ENABLED_OUTPUTS=()
EDIDS=$(xrandr --props | awk 'BEGIN { current = ""; output = ""; }
$2 == "connected" { output = $1; }
$0 ~ /:/ {
   if ($1 == "EDID:") { current = output; printf current " " }
   else if (current != "") { printf "\n"; current = "" }
}
$0 !~ /:/ { if (current != ""){ printf $1 } }
')
SAVED_PROFILES=${PROFILE_LOCATION:-$HOME/.config/display_profiles}

if [ ! -e $SAVED_PROFILES ]; then
    touch $SAVED_PROFILES
fi

is_in() {
   local SET=$1
   local TARGET=$2
   echo $SET | tr ' ' '\n' | egrep "^$TARGET\$" > /dev/null
   return $?
}

is_connected() { is_in "$CONNECTED_DISPLAYS" $1; return $?; }
is_active() { is_in "$ACTIVE_DISPLAYS" $1; return $?; }
is_enabled() { is_in "$ENABLED_OUTPUTS" $1; return $?; }

lid_open() {
   if [[ "$LID_STATE" == "open" ]]; then
      return 0
   else
      return 1
   fi
}

print_info() {
   local _DISPLAY=$1

   printf "$_DISPLAY:\t"

   if is_connected $_DISPLAY; then printf "connected "
   else printf "disconnected "; fi

   if is_active $_DISPLAY; then printf "active "
   else printf "inactive "; fi

   printf "\n"
}

get_profile() {
    local _DISPLAY=$1

    local _EDID=$(echo $EDIDS | egrep "^$_DISPLAY" | cut -d' ' -f2-)
    local PROFILE=$(cat $SAVED_PROFILES | grep "$_EDID " | cut -d' ' -f2-)

    echo $PROFILE
}

ACTION=${1:-auto}

for _DISPLAY in $CONNECTED_DISPLAYS; do
   if [[ "$_DISPLAY" != "$BUILTIN_DISPLAY" ]]; then
      EXTERNAL_DISPLAY=$_DISPLAY
   fi
done

case $ACTION in
   "external"|"ex"|"x")
      if [[ -z "$EXTERNAL_DISPLAY" ]]; then
         echo "No external display detected"
         exit 1
      fi

      ENABLED_OUTPUTS+=($EXTERNAL_DISPLAY)
      ;;
   "clone"|"cl"|"c")
      ENABLED_OUTPUTS+=($BUILTIN_DISPLAY $EXTERNAL_DISPLAY)
      ;;
   "builtin"|"internal"|"i")
      ENABLED_OUTPUTS+=($BUILTIN_DISPLAY)
      ;;
   "switch"|"sw")
      if [[ -z "$EXTERNAL_DISPLAY" ]]; then
         if is_active $BUILTIN_DISPLAY; then
            echo "No external display to toggle to"
            exit 1
         else
            ENABLED_OUTPUTS+=($BUILTIN_DISPLAY)
         fi
      else
         if is_active $BUILTIN_DISPLAY; then
            ENABLED_OUTPUTS+=($EXTERNAL_DISPLAY)
         else
            ENABLED_OUTPUTS+=($BUILTIN_DISPLAY)
         fi
      fi
      ;;
   "status"|"st")
      for _DISPLAY in $CONNECTED_DISPLAYS; do
         print_info $_DISPLAY
         _PROFILE=$(get_profile $_DISPLAY)
         if [[ ! -z "$_PROFILE" ]]; then
             echo "Saved Profile: $_PROFILE"
         fi
      done

      exit 0
      ;;
   "auto")
      if lid_open; then
         if [[ -z "$EXTERNAL_DISPLAY" ]]; then
            ENABLED_OUTPUTS+=($BUILTIN_DISPLAY)
         else
            ENABLED_OUTPUTS+=($EXTERNAL_DISPLAY $BUILTIN_DISPLAY)
         fi
      else
         if [[ -z "$EXTERNAL_DISPLAY" ]]; then
            ENABLED_OUTPUTS+=($BUILTIN_DISPLAY)
         else
            ENABLED_OUTPUTS+=($EXTERNAL_DISPLAY)
         fi
      fi
      ;;
   *)
      exit 1
      ;;
esac

for _DISPLAY in $ACTIVE_DISPLAYS; do
   if ! is_connected $_DISPLAY; then
      xrandr --output $_DISPLAY --off
   fi
done

for _DISPLAY in $CONNECTED_DISPLAYS; do
   if is_enabled $_DISPLAY; then
      is_active $_DISPLAY || xrandr --output $_DISPLAY --auto $(get_profile $_DISPLAY)
   elif is_active $_DISPLAY; then
      xrandr --output $_DISPLAY --off
   fi
done

xdotool key super+q
wallpaper
