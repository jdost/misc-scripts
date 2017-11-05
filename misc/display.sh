#!/bin/sh

if [[ -z "$XAUTHORITY" ]]; then
   export XAUTHORITY=$(ps -C Xorg -f --no-header | sed -n '$/.*-auth //; s/ -[^ ].*//; p')
fi
if [[ -z "$DISPLAY" ]]; then
   displays=`ls /tmp/.X11-unix/* | sed s#/tmp/.X11-unix/X##`
   export DISPLAY=":$displays.0"
fi

BUILTIN_DISPLAY="eDP-1"
EXTERNAL_DISPLAY=""
CONNECTED_DISPLAYS=$(xrandr | grep " connected " | cut -d' ' -f1)
ACTIVE_DISPLAYS=$(xrandr --listactivemonitors | tail -n +2 | awk '{ print $NF }')
LID_STATE="$(cat /proc/acpi/button/lid/LID0/state | cut -d':' -f2 | sed -e 's/[ \t]*//')"
ENABLED_OUTPUTS=()

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
   "auto")
      if is_open; then
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
      done

      exit 0
      ;;
   *)
      ;;
esac

for _DISPLAY in $CONNECTED_DISPLAYS; do
   if is_enabled $_DISPLAY; then
      is_active $_DISPLAY || xrandr --output $_DISPLAY --auto
   elif is_active $_DISPLAY; then
      xrandr --output $_DISPLAY --off
   fi
done
