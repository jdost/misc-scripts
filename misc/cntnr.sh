#!/bin/zsh

# Attempt to wrap control over running containers

if [[ $EUID -ne 0 ]]; then
   sudo EDITOR=$EDITOR $0 $*
   exit $?
fi

# System Location
TEMPLATE_DIR=/usr/share/lxc/templates
CONTAINER_DIR=/var/lib/lxc

# Settings
SHOW_HELP=0
DEFAULT_DISTRO="archlinux"
typeset -a HELPS
HELPS=()

typeset -a TEMPLATES
get_templates() {
   TEMPLATES=($(ls $TEMPLATE_DIR | cut -d'-' -f2-))
}
typeset -a CONTAINERS
get_containers() {
   CONTAINERS=($(lxc-ls))
}

display_array() {
   for e in $@; do
      print $e
   done
}

check_name() {
   if [[ $#CONTAINERS -eq 0 ]]; then
      get_containers
   fi

   if [[ -z "$1" ]]; then
      print "A name is required for the container."
      exit 1
   elif [[ $CONTAINERS[(i)$1] -gt $#CONTAINERS ]]; then
      print "$1 is not an available container."
      exit 1
   fi
}

usage() {
   cat << EOF
$0 ACTION [...]
   ACTION is one of:

EOF

   for h in $HELPS; do
      $h
   done

   exit 0
}

while (( $# )); do
   case "$1" in
      "-h"|"--help") SHOW_HELP=1 ;;
      *) break ;;
   esac

   shift
done
# CREATE
create_usage() {
   cat << EOF
   create [-l] [-d DISTRO] NAME

      -d|--distro - linux distribution/lxc template to create from
      -l|--ls     - lists available distributions

      NAME is the name of the container to be created

EOF
}
HELPS+=(create_usage)

create() {
   get_templates
   get_containers

   local distro=$DEFAULT_DISTRO
   local name=""

   while (( $# )); do
      case "$1" in
         "-h"|"--help")
            create_usage
            exit 0
            ;;
         "-l"|"--ls")
            display_array $TEMPLATES
            exit 0
            ;;
         "-d"|"--distro")
            shift
            distro=$1
            ;;
         *) name=$1
            ;;
      esac

      shift
   done

   if [[ $TEMPLATES[(i)$distro] -gt $#TEMPLATES ]]; then
      print "$distro is not an available template for creation."
      exit 1
   fi

   if [[ -z "$name" ]]; then
      print "A name is required for the container."
      exit 1
   elif [[ $CONTAINERS[(i)$name] -lt ($#CONTAINERS + 1) ]]; then
      print "There is already a container with the name $name."
      exit 1
   fi

   lxc-create -n $name -t $TEMPLATE_DIR/lxc-$distro
}
# CONFIGURE
config_usage() {
   cat << EOF
   conf[igure] [-l] NAME

      -l|--ls - lists available containers

      NAME is the name of the container to configure

EOF
}
HELPS+=(config_usage)

configure() {
   get_containers

   while (( $# )); do
      case "$1" in
         "-l"|"--ls")
            display_array $CONTAINERS
            exit 0
            ;;
         *) name=$1
            ;;
      esac

      shift
   done

   check_name $name

   $EDITOR $CONTAINER_DIR/$name/config
}
# STATUS
status_usage() {
   cat << EOF
   st[atus] [NAME]

      Displays the status of all containers running or the specified container
EOF
}
HELPS+=(status_usage)

stat() {
   if [[ ! -z "$1" ]]; then
      local target="$1"
      lxc-info -n $target
   else
      lxc-ls -f
   fi
}
# START
boot_usage() {
   cat << EOF
   s[tart] NAME

      NAME is the name of the container to be started

EOF
}
HELPS+=(boot_usage)

boot() {
   get_containers
   local target=""

   while (( $# )); do
      case "$1" in
         *) target=$1 ;;
      esac

      shift
   done

   check_name $target

   lxc-start -n $target
}
# CONNECT
connect_usage() {
   cat << EOF
   c[onnect] NAME

      NAME is the name of the container to connect to

EOF
}
HELPS+=(connect_usage)

connect() {
   get_containers
   local target=""

   while (( $# )); do
      case "$1" in
         *) target=$1 ;;
      esac

      shift
   done

   check_name $target

   lxc-attach -n $target
}
# STOP
close_usage() {
   cat << EOF
   stop NAME

      NAME is the name of the container to be stopped

EOF
}
HELPS+=(close_usage)

close() {
   get_containers
   local target=""

   while (( $# )); do
      case "$1" in
         *) target=$1 ;;
      esac

      shift
   done

   check_name $target

   lxc-stop -n $target
}
# DESTROY
destroy_usage() {
   cat << EOF
   d[estroy] NAME

      NAME is the name of the container to be destroyed

EOF
}
HELPS+=(destroy_usage)

destroy() {
   get_containers
   local target=""

   while (( $# )); do
      case "$1" in
         *) target=$1 ;;
      esac

      shift
   done

   check_name $target

   lxc-destroy -n $target
}

if [[ "$SHOW_HELP" == "1" ]]; then
   usage
fi

case "$1" in
   "create")
      shift
      create $@
      ;;
   "config"|"conf"|"configure")
      shift
      configure $@
      ;;
   "status"|"st")
      shift
      stat $@
      ;;
   "start"|"s")
      shift
      boot $@
      ;;
   "connect"|"c")
      shift
      connect $@
      ;;
   "stop")
      shift
      close $@
      ;;
   "delete"|"d")
      shift
      destroy $@
      ;;
   *) ;;
esac

# vim:ft=sh
