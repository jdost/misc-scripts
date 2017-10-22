#!/bin/sh

version_python() { python --version 2>&1 | cut -d' ' -f2-; }
version_ruby() { ruby --version | cut -d' ' -f2-; }
version_go() { go version | cut -d' ' -f3-; }
version_gcc() { gcc -v 2>&1 | grep version | cut -d' ' -f2-; }
version_ghc() { ghc -V | rev | cut -d' ' -f1 | rev; }

if [[ $# -gt 0 ]]; then
   targets=$*
else
   targets="gcc ghc go python ruby"
fi

green() { echo -en "\033[32m$($*)\033[0m"; }
white() { echo -en "\033[1m\033[37m$($*)\033[0m"; }

for lang in $targets; do
   echo -e "   $(green echo "$lang")   $(white version_$lang)"
done

