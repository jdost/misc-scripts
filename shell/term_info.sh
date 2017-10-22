#!/bin/sh

BOLD="\033[1m"
UNDERLINE="\033[4m"
RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
BROWN="\033[33m"
BLUE="\033[34m"
PURPLE="\033[35m"
CYAN="\033[36m"
LGREY="\033[37m"

# Text Effects
bold() { echo -en "${BOLD}$($*)${RESET}"; }
underline() { echo -en "${UNDERLINE}$($*)${RESET}"; }
line() { echo -e "$($*)"; }

# Colors
black() { echo -en "${BLACK}$($*)${RESET}"; }
dark_grey() { bold black $*; }
red() { echo -en "${RED}$($*)${RESET}"; }
pink() { bold red $*; }
green() { echo -en "${GREEN}$($*)${RESET}"; }
light_green() { bold green $*; }
brown() { echo -en "${BROWN}$($*)${RESET}"; }
yellow() { bold brown $*; }
blue() { echo -en "${BLUE}$($*)${RESET}"; }
light_blue() { bold blue $*; }
purple() { echo -en "${PURPLE}$($*)${RESET}"; }
magenta() { bold purple $*; }
cyan() { echo -en "${CYAN}$($*)${RESET}"; }
light_cyan() { bold cyan $*; }
light_grey() { echo -en "${LGREY}$($*)${RESET}"; }
white() { bold light_grey $*; }

# Information
_jobs() { echo $(ps t | egrep -v "term_info|ps.t|zsh|STAT|sed|wc" | sed "/^$/d" | wc -l); }
_tty() { echo $(tty | cut -d'/' -f3-); }
_time() { echo $(date +"%b %d %R"); }
_uptime() { echo $(uptime -p | cut -d' ' -f2- | sed 's/ days,/d/' | sed 's/ hours,/h/' | sed 's/ minutes/m/'); }
_username() { echo $USER; }
_hostname() { hostname; }
_ip() { hostname -i; }
_directory() { echo $PWD; }
_shell() { echo $SHELL; }
_kernel() { uname -srmo; }
python_version() { 
    if which python 2>/dev/null >/dev/null; then
        python --version 2>&1 | cut -d' ' -f2- 
    elif which python2 2>/dev/null >/dev/null; then
        python2 --version 2>&1 | cut -d' ' -f2- 
    else
        echo 'uninstalled'
    fi
}
ruby_version() { 
    if which ruby 2>/dev/null >/dev/null; then
        ruby --version | cut -d' ' -f2
    else
        echo 'uninstalled'
    fi
}

venv_name() { echo $(basename ${VIRTUAL_ENV:-''}); }
ssh_info() { echo ''; }

tmux_name() { echo "$(tmux ls | grep attached | cut -d':' -f1)"; }
tmux_info() { echo "$(tmux list-panes | wc -l) panes / $(tmux list-windows | wc -l) windows"; }

ssh_info() { echo "$(echo $SSH_CONNECTION | cut -d' ' -f1-2 --output-delimiter=':')->$(echo $SSH_CONNECTION | cut -d' ' -f3-4 --output-delimiter=':')"; }

#  if SSH: ssh info

echo ''
echo -e "  $(light_green echo 'User:') $(blue _username)\t$(light_green echo 'Host:') $(blue _hostname)\t$(light_green echo 'Directory:') $(blue _directory)"
echo -e "   $(light_green echo 'TTY:') $(blue _tty)\t$(light_green echo 'Jobs:') $(blue _jobs)   \t$(light_green echo 'Shell:') $(blue _shell)"
echo -e "   $(light_green echo 'Time:') $(blue _time)\t\t$(light_green echo 'Uptime:') $(blue _uptime)"
echo -e "   $(light_green echo 'Kernel:') $(blue _kernel)"
echo -e "   $(pink echo 'Python:') $(light_grey python_version)\t\t$(pink echo 'Ruby:') $(light_grey ruby_version)"

NEW_LINE=''
new_line() {
   if [[ -z "$NEW_LINE" ]]; then
      echo ''
      NEW_LINE=' '
   fi
}
# Python virtualenv
if [[ ! -z $(venv_name) ]]; then
   new_line
   echo -e "  $(brown echo 'Virtual Env:') $(white venv_name)"
fi
# Active SSH connection
if [[ ! -z "$SSH_CONNECTION" ]]; then
   new_line
   echo -e "  $(brown echo 'SSH:') $(white ssh_info)"
fi
# Active Tmux session
if [[ ! -z "$TMUX" ]]; then
   new_line
   echo -e "  $(brown echo 'Tmux:') $(white tmux_name) - $(white tmux_info)"
fi

echo ''