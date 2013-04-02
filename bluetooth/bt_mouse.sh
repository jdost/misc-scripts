#!/bin/sh

MOUSE=''
if [ $1 == 'on']; then
   ACTION='--connect'
else
   ACTION='--kill'
fi

hidd $ACTION $MOUSE
