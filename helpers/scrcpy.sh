#!/usr/bin/env bash
# Helper wrapper for scrcpy to allow for detecting whether the target is over wifi
#   or hardlines (usb cable) and optimizing the connection to match

set -euo pipefail

# Trick to determine the next executable in the path precedence so that this can
#   forward the determined arguments to it (since it is wrapping the underlying
#   executable).
if [[ "$(which scrcpy)" != "$(which -a scrcpy)" ]]; then
   ALIASED_SCRCPY_LEN=$(which scrcpy | wc -l)
   SCRCPY_BIN=$(which -a scrcpy | sed -e "1,$ALIASED_SCRCPY_LEN"d | head -n1)
else
   SCRCPY_BIN=$(which scrcpy)
fi

# Ensure the adb server is up, otherwise subsequent command fails when the server
#   launches
adb start-server 1>/dev/null
# If args are passed, treat it as a straight passthrough
[[ "$#" != "0" ]] && exec $SCRCPY_BIN "$@"

DEVICES=$(adb devices | grep -e "device$" | awk '{ print $1 }')

if [[ "$(echo $DEVICES | head -n1)" == *":"* ]]; then
   exec $SCRCPY_BIN --bit-rate 2M --max-size 800 --max-fps 15
else
   exec $SCRCPY_BIN
fi
