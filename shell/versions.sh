#!/bin/sh

version_python() { if which python > /dev/null 2>&1 ; then python --version 2>&1 | cut -d' ' -f2-;
    else echo -en "Uninstalled"; fi }
version_ruby() {
    if which ruby > /dev/null 2>&1 ; then ruby --version | cut -d' ' -f2-;
    else echo -en "Uninstalled"; fi }
version_go() {
    if which go > /dev/null 2>&1 ; then go version | cut -d' ' -f3-;
    else echo -en "Uninstalled"; fi }
version_gcc() {
    if which gcc > /dev/null 2>&1 ; then gcc -v 2>&1 | grep version | cut -d' ' -f2-;
    else echo -en "Uninstalled"; fi }
version_ghc() {
    if which ghc > /dev/null 2>&1 ; then ghc -V | rev | cut -d' ' -f1 | rev;
    else echo -en "Uninstalled"; fi }
version_docker() {
    if which docker > /dev/null 2>&1 ; then docker --version | cut -d' ' -f3 | sed 's/,//';
    else echo -en "Uninstalled"; fi }

if [[ $# -gt 0 ]]; then
   targets=$*
else
   targets="gcc ghc go python ruby docker"
fi

green() { echo -en "\033[32m$($*)\033[0m"; }
white() { echo -en "\033[1m\033[37m$($*)\033[0m"; }

for lang in $targets; do
   echo -e "   $(green echo "$lang")   $(white version_$lang)"
done

