#!/bin/sh

set -euo pipefail
# Resolve the underlying tmux binary
if [[ "$(which git)" != "$(which -a git)" ]]; then
   ALIASED_GIT_LEN=$(which git | wc -l)
   GIT_BIN=$(which -a git | sed -e "1,$ALIASED_GIT_LEN"d | head -n 1)
else
   GIT_BIN=$(which git)
fi

case "${1:-}" in
   "")
      exec $GIT_BIN
      ;;
   "grep")
      if [[ ! -z "$(which rg 2>/dev/null)" ]]; then
         shift # Remove the `grep` argument
         exec rg "$@"
      else
         exec $GIT_BIN "$@"
      fi
      ;;
   "--raw") # Provide a bypass, this will skip the overrides above
      shift
      exec $GIT_BIN "$@"
      ;;
   *)
      exec $GIT_BIN "$@"
      ;;
esac
