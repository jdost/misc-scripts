#!/bin/sh

# Attempt to add some creation aliasing (mkdir, touch/edit new file)

FILEPATH=$1

# Parse FILEPATH

FILENAME=$(echo "$FILEPATH" | sed -e 's/\//\n/g' | tail -n1)
if [[ ! -z "$FILENAME" ]]; then
   LENGTH=$((${#FILENAME}+1))
   FOLDERS=$(echo "$FILEPATH" | rev | cut -c $LENGTH- | rev)
else
   FOLDERS=$FILEPATH
fi

if [[ ! -z "$FOLDERS" ]]; then
   mkdir -p $FOLDERS
fi

if [[ ! -z "$FILENAME" ]]; then
   EXTENSION=$(echo "$FILENAME" | rev | cut -d'.' -f1 | rev)
   if [[ $EXTENSION = $FILENAME ]]; then
      EXTENSION=""
   fi

   touch $FILEPATH
   # if extension is in some list, open with $EDITOR?
fi
