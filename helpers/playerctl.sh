#!/bin/zsh
# Helper wrapper for playerctl to better determine player targetting
#   This is for when you have a long running player (like spotify) and start
#   playing another audio source (like chromium) on top, this will detect that
#   chromium is currently playing and target that

set -euo pipefail

# Trick to determine the next executable in precedence so this can forward to it
#   This is useful to leave this in the path and wrap the underlying target so we
#   don't need to hardcode a target or do something cute
if [[ "$(which playerctl)" != "$(which -a playerctl)" ]]; then
   ALIASED_PLAYERCTL_LEN=$(which playerctl | wc -l)
   PLAYERCTL_BIN=$(which -a playerctl | sed -e "1,$ALIASED_PLAYERCTL_LEN"d | head -n1)
else
   PLAYERCTL_BIN=$(which playerctl)
fi

# Print out all players with the format:
#   <playing|paused>,<identifier>
ALL_PLAYERS=$(
   $PLAYERCTL_BIN metadata -a --format "{{lc(status)}},{{playerName}}" 2>/dev/null
)

# Grab the first playing source
if echo $ALL_PLAYERS | grep -e "^playing" &>/dev/null; then
   TARGET_PLAYER=$(echo $ALL_PLAYERS | grep -e "^playing" | cut -d',' -f2- | head -n1)
else  # fall back to the first player, which is the default
   TARGET_PLAYER=$(echo $ALL_PLAYERS | head -n1 | cut -d',' -f2-)
fi

if [[ -z "$TARGET_PLAYER" ]]; then
   echo "No active player"
   exit 1
fi

# Useful debugging output to show what the wrappe *thinks* it should target
if [[ "${1:-}" == "get-active" ]]; then
   echo $TARGET_PLAYER
   exit 0
fi

exec $PLAYERCTL_BIN --player=$TARGET_PLAYER "$@"
