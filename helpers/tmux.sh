#!/usr/bin/env bash

set -euo pipefail
# Resolve the underlying tmux binary
if [[ "$(which tmux)" != "$(which -a tmux)" ]]; then
   ALIASED_TMUX_LEN=$(which tmux | wc -l)
   TMUX_BIN=$(which -a tmux | sed -e "1,$ALIASED_TMUX_LEN"d | head -n 1)
else
   TMUX_BIN=$(which tmux)
fi

TMUX_TMPDIR=/tmp/tmux-$UID
DEFAULT_TMUX=default

[[ ! -d "$TMUX_TMPDIR" ]] && mkdir -p "$TMUX_TMPDIR"


_start () {
   local name=$1
   if [[ ! -S "$TMUX_TMPDIR/$name" ]]; then
      $TMUX_BIN -L $name new-session -s $name -d
      #chmod 777 $TMUX_TMPDIR/$name
   fi
   _attach $name
}

_attach () {
   local name=$1
   settitle "$name"
   exec $TMUX_BIN -L $name attach -t $name
}

_check_in_session () {
   if [[ -z "${TMUX:-}" ]]; then
      echo "!!! Not currently in a tmux session"
      exit 1
   fi
}

case "${1:-}" in
   "")
      _start "$DEFAULT_TMUX"
      ;;
   start|new|s)
      shift
      _start "${1:-$DEFAULT_TMUX}"
      ;;
   attach|a)
      shift
      _attach "${1:-$DEFAULT_TMUX}"
      ;;
   detach|d)
      _check_in_session
      exec $TMUX_BIN detach
      ;;
   layout|l)
      _check_in_session
      shift
      exec $TMUX_BIN source $XDG_CONFIG_HOME/tmux/${1:-default}
      ;;
   ls)
      exec ls $TMUX_TMPDIR
      ;;
   "--raw") # Provides a bypass, `--raw ...` will skip the above overrides
      shift
      exec $TMUX_BIN "$@"
      ;;
   *)
      exec $TMUX_BIN "$@"
      ;;
esac
