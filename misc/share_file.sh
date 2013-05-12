#!/bin/sh

SHARE_DIR=$HOME/http/share/
SHARE_FILE="$PWD/$1"
if [ ! -f "$SHARE_FILE" ]; then
   echo "FILE: $SHARE_FILE does not exist, exiting..."
   exit 2
fi

# Make folder to share in
SHARE_FOLDER=`uuidgen`
SHARE_DEST=$SHARE_DIR$SHARE_FOLDER
mkdir $SHARE_DIR$SHARE_FOLDER

# Link file in the share directory
SHARE_BASE=`basename "$SHARE_FILE"`
#ln -s $SHARE_FILE $SHARE_DEST/$SHARE_BASE
cp "$SHARE_FILE" "$SHARE_DEST/$SHARE_BASE"
sudo chgrp http "$SHARE_FILE"
sudo chmod g+r "$SHARE_FILE"

# Print URL to share this
URL_BASE=${SHARE_URL:-http://localhost/}/$SHARE_FOLDER/$SHARE_BASE
echo $URL_BASE
