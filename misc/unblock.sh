#!/bin/sh

if [[ $# -eq 0 ]]; then
   ports=""
   while read p ; do
      ports+=" $p"
   done
else
   ports=$@
fi

for port in $ports; do
   pid=$(lsof -i TCP:$port | grep -v COMMAND | awk '{print $2}' | sort | uniq)
   echo "Killed $(ps -p $pid -o comm=) ($pid) running on $port"
   kill $pid
done

