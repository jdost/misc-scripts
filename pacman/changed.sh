#!/bin/sh

for package in /var/lib/pacman/local/*; do
   sed '/^%BACKUP%$/,/^%/!d' $package/files | tail -n+2 | grep -v '^$' | while read file hash; do
      [ "$(md5sum /$file | (read hash file; echo $hash))" != "$hash" ] && echo $(basename $package) /$file
   done
done
