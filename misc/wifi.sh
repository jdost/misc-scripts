DEFAULT=apartment

CURRENT=$(netctl list | grep "^\*" | cut -d' ' -f 2)
INTERFACE=$(iwconfig 2> /dev/null | grep -v "^ " | grep IEEE | cut -d' ' -f1)

power() {
   local STATUS=$(iwconfig $INTERFACE | grep "Tx-Power" | sed 's/\ /\n/g' | grep "Tx-Power" | cut -d'=' -f2)
   if [[ $1 == "on" ]]; then
      [[ $STATUS == "off" ]] && sudo iwconfig $INTERFACE txpower on
   else
      [[ $STATUS != "off" ]] && sudo iwconfig $INTERFACE txpower off
   fi
}

if [[ $# == 0 ]]; then
   if [[ -z "$CURRENT" ]]; then
      sudo netctl connect $DEFAULT
   else
      sudo netctl restart $CURRENT
   fi

   exit $?
fi

case $1 in
   search)
      #power on
      sudo wifi-menu
      ;;
   stop|dc|disconnect)
      sudo netctl stop-all
      #power off
      ;;
   on)
      power on
      ;;
   off)
      power off
      ;;
   start|c|connect)
      #power on
      if [[ ! -z "$CURRENT" ]]; then
         sudo netctl stop $CURRENT
      fi
      sudo netctl start ${2:-$DEFAULT}
      ;;
   restart|r)
      #power on
      sudo netctl restart $CURRENT
      ;;
   *)
      sudo netctl $*
      ;;
esac
