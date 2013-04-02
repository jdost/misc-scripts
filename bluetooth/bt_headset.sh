#!/bin/sh

NORM="/etc/asound.conf.reg"
BT="/etc/asound.conf.bt"
DEST="/etc/asound.conf"
DEV="btheadset"

case "$1" in
   on)
      sudo /etc/rc.d/bluetooth start
      #sudo cp $BT $DEST
      ;;
   load)
      pactl load-module module-alsa-sink device=$DEV
      pactl load-module module-alsa-source device=$DEV
      ;;
   off)
      sudo /etc/rc.d/bluetooth stop
      #sudo cp $NORM $DEST
      ;;
   *)
      ;;
esac
