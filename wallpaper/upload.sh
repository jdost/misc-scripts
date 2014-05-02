#!/bin/sh

URLS=""

while read URL; do
   if [[ -z "$URLS" ]]; then
      URLS=$URL
   else
      URLS="$URL\n$URLS"
   fi
done

echo $URLS | ssh wallpapers "cat - >> drop/$HOSTNAME"
