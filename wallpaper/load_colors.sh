DSC="\033P"
OSC="\033]"

send_command () {
   seq="$1"
   [ ! -z "$TMUX" ] && seq="${DSC}tmux;\033${seq}\033\\"

   printf "${seq}"
}

send_color () {
   color="$1;$2"
   send_command "${OSC}4;${color}\007"
}

send_fg () {
   color="$1"
   send_command "${OSC}10;${color}\007"
}

send_bg () {
   color="$1"
   send_command "${OSC}11;${color}\007"
}

xrdb -merge $XDG_CONFIG_HOME/X11/Xresources

for combo in $(xrdb -query | grep "\*color" | awk '{ gsub(/[colr\:\*]/,"",$1); print $1 "," $2 }'); do
   color_num=$(echo $combo | cut -d',' -f1)
   color_value=$(echo $combo | cut -d',' -f2)
   send_color $color_num $color_value
done

send_fg $(xrdb -query | grep foreground | awk '{ print $2 }')
send_bg $(xrdb -query | grep background | awk '{ print $2 }')
