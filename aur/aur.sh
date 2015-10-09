#!/bin/sh

aur_get() {
   cd ${AUR_HOME:-$HOME/.local/aur}
   if [[ -d "$1" ]]; then
      aur_update $1
      return
   fi

   if ! git clone "https://aur.archlinux.org/$1.git"; then
      echo "Failed to retrieve package $1."
      return 1
   fi
   cd "$1"
   makepkg -si
   #if makepkg > /dev/null; then
      #sudo pacman -U "$(ls -t --file-type | grep tar | head -1)"
   #fi
}

aur_update() {
   cd ${AUR_HOME:-$HOME/.local/aur}
   if [[ "$1" == "all" ]]; then
      for f in *; do
         aur_update $f
         cd $HOME/.local/aur/
      done
      return 0
   fi
   if [[ ! -d "$1" ]]; then
      echo "Package $1 is not already installed."
      return 1
   fi

   cd "$1"
   git pull
   makepkg -si
   #if makepkg > /dev/null; then
      #sudo pacman -U "$(ls -t --file-type | grep tar | head -1)"
   #fi
}

if [[ -z "${1}" ]]; then
   echo "Missing argument (1 required)"
   return 1
fi

case "$1" in
   ('get'|'install')
      aur_get $2 ;;
   ('update'|'upgrade')
      aur_update $2 ;;
   (*) aur_get $1 ;;
esac
