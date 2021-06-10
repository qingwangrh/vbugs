#!/bin/bash
#auto extend lvm
echo "$$" >/tmp/extend_lvm.pid
echo "$$"
trap 'extend pause 1024M' SIGRTMIN
trap 'rm -f /tmp/extend_lvm.pid' EXIT

extend() {
  echo "extend... $1 $2"
  if mount | grep vg-lv1; then
    lvextend --autobackup n --size +$2 /dev/vg/lv1 --resizefs >/dev/null
  else
    lvextend --autobackup n --size +$2 /dev/vg/lv1 >/dev/null
  fi

  lvchange --refresh vg/lv1
  lvs vg/lv1 --noheadings

}

while true; do
  #5-8s
  time=$((($RANDOM % 3 + 5) * 10))
  echo "sleep $time"
  for ((i = 1; i < time; i++)); do
    sleep 0.1
  done
  if [[ -f /tmp/monitor.pid ]]; then
    kill -SIGRTMIN $(cat /tmp/monitor.pid)
  fi
  extend time 512M
done
