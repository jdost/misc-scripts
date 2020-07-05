#!/usr/bin/env bash

set -euo pipefail

USR_BIN="$HOME/.local/bin"

linkIfNot() {
   src=$1
   tgt=$2
   if [[ -e "$tgt" ]]; then
      echo "WARNING: $tgt already exists..."
      return
   fi
   ln -s $PWD/$src $tgt
}

pkginstall() {
   sudo pacman -S --needed --noconfirm "$@"
}

case "${1:-}" in
   "display")
      pkginstall xorg-xrandr
      linkIfNot misc/display.sh $USR_BIN/display
      ;;
   "docker")
      pkginstall docker
      linkIfNot helpers/docker.sh $USR_BIN/docker
      ;;
   "git")
      pkginstall git ripgrip
      linkIfNot helpers/git.sh $USR_BIN/git
      ;;
   "lock")
      pkginstall mpv xsecurelock xss-lock
      [[ -e "/usr/lib/xsecurelock/saver_mpv-cinemagraph" ]] || \
         sudo ln -s $PWD/lock/saver_mpv-cinemagraph /usr/lib/xsecurelock/saver_mpv-cinemagraph
      linkIfNot lock/lock.sh $USR_BIN/screenlock
      [[ -d "$XDG_CONFIG_HOME/supervisord/config.d" ]] \
         && linkIfNot lock/screenlock.conf $XDG_CONFIG_HOME/supervisord/config.d/screenlock.conf
      ;;
   "term")
      linkIfNot shell/settitle.sh $USR_BIN/settitle
      linkIfNot shell/term_info.sh $USR_BIN/term_info
      ;;
   "tmux")
      pkginstall tmux
      linkIfNot helpers/tmux.sh $USR_BIN/tmux
      ;;
   "wallpaper")
      pkginstall feh
      linkIfNot wallpaper/wallpaper.sh $USR_BIN/wallpaper
      ;;
   *)
      echo "Please provide a valid setup target..."
      exit 1
      ;;
esac
