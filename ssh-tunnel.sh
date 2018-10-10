#!/usr/bin/env bash

args=$@

host=""
port=""
user=""
pass=""
key=""
listen=""

parse_opts() {

  local options=$(getopt -l "host:,port:,user:,pass:,key:,listen:,action:" -o -a -- $args)

  if [ $? -eq 1 ]; then
    exit 1;
  fi

  eval set -- "$options"

  while true ; do
    case "$1" in
      --host) host=$2 ; shift 2 ;;
      --port) port=$2 ; shift 2 ;;
      --user) user=$2 ; shift 2 ;;
      --pass) pass=$2 ; shift 2 ;;
      --key) key=$2 ; shift 2 ;;
      --listen) listen=$2 ; shift 2 ;;
      --action) action=$2 ; shift 2 ;;
      --) shift ; break ;;
      *) echo "unexpected arg: $1" ; exit 1 ;;
    esac
  done
}

CFG_FILE="$HOME/.`basename $0 .sh`.cfg"

get_pid() {
  pgrep -f "$1"
}

has_cfg() {
  if [ -f "$CFG_FILE" ]; then
    return 0
  else
    return 1
  fi
}

ensure_cfg() {
  if ! has_cfg; then
    echo "no config found, please setup before use"
    exit 1  else
  fi
}

is_running() {
  . $CFG_FILE > /dev/null 2>&1
  local pid=$(get_pid "$cmd")
  if [ "$pid" != "" ]; then
    return 0
  else
    return 1
  fi
}

setup() {
  local msg=""
  if [ "$host" = "" ]; then
    msg+="please specify host via: --host\n"
  fi

  if [ "$port" = "" ]; then
    msg+="please specify port via: --port\n"
  fi

  if [ "$user" = "" ]; then
    msg+="please specify user via: --user\n"
  fi

  if [ "$pass" = "" ] && [ "$key" = "" ]; then
    msg+="please specify pass or key: --pass or --key\n"
  fi

  if [ "$listen" = "" ]; then
    msg+="please specify local port via: --listen\n"
  fi

  if [ "$msg" != "" ]; then
    echo -e "$msg"
    exit 1
  fi

  local cmd=""
  if [ "$pass" != "" ]; then
    cmd="ssh -qTfnN -D $listen -o ServerAliveInterval=60 -o ServerAliveCountMax=60 $user@$host -p $port"
  else
    cmd="ssh -qTfnN -D $listen -o ServerAliveInterval=60 -o ServerAliveCountMax=60 -i $key $user@$host -p $port"
  fi

  typeset -p host port user pass key listen cmd > $CFG_FILE
}

start() {
  ensure_cfg

  . $CFG_FILE > /dev/null 2>&1

  if is_running; then
    local pid=$(get_pid "$cmd")
    echo "a ssh-tunnel instance is already running, pid: $pid"
    exit 0
  fi

  echo "starting..."

  if [ "$pass" != "" ]; then
    echo "using pass..."

    expect <(cat <<EOF
log_user 0

spawn -ignore HUP $cmd

expect {
  timeout { send_user "\nunable to get password prompt\n"; exit 1 }
  eof { send_user "\nssh failure for $host, please check you network\n"; exit 1 }
  "*assword" {
    send "$pass\r"
  }
}

EOF
)
  else
    echo "using key..."
    eval $cmd
  fi

  local pid=$(get_pid "$cmd")
  echo "ssh-tunnel is running"
}

stop() {
  echo "stopping..."
  . $CFG_FILE > /dev/null 2>&1
  if [ "$cmd" != "" ]; then
    readarray -t pids <<< $(pgrep -f "$cmd")
    for pid in "${pids[@]}"; do
      echo "killing pid: $pid"
      if [ "$pid" != "" ]; then
        kill $pid > /dev/null 2>&1
      fi
    done
  fi
  echo "stopped"
}

restart() {
  stop
  start
}

do_action() {
  case "$action" in
    start) start ;;
    stop) stop ;;
    restart) restart ;;
    *) setup ;;
  esac
}

has_cmd() {
  type "$1" > /dev/null 2>&1
}

prepare_cmd() {
  declare -gx a=1
  if ! has_cmd expect; then
    echo "expect is not installed, try to install..."
    sudo apt install -y expect
  fi
}

prepare_cmd
parse_opts
do_action
