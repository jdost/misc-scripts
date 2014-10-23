#!/bin/sh

URLS=""

while read URL; do
   if [[ -z "$URLS" ]]; then
      URLS=$URL
   else
      URLS="$URL $URLS"
   fi
done

echo $URLS | ssh wallpapers "sed \"s/ /\n/g\" >> drop/$HOSTNAME"
