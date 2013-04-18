#!/bin/sh

aur_get() {
   cd $HOME/.aur/
   if [[ -d "$1" ]]; then
      aur_update $1
      return
   fi

   ABBR=${1:0:2}
   if ! wget "http://aur.archlinux.org/packages/$ABBR/$1/$1.tar.gz"; then
      echo "Failed to retrieve package $1."
      return 1
   fi
   tar -xzf "$1.tar.gz"
   rm "$1.tar.gz"
   cd "$1"
   makepkg
}

aur_update() {
   cd $HOME/.aur/
   if [[ "$1" == "all" ]]; then
      for f in *; do
         aur_update $f
         cd $HOME/.aur/
      done
      return 0
   fi
   if [[ ! -d "$1" ]]; then
      echo "Package $1 is not already installed."
      return 1
   fi

   cd "$1"
   makepkg
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
