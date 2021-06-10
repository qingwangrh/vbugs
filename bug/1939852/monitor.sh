#!/bin/bash

echo "$$">/tmp/monitor.pid
echo "$$"

extend() {
  echo "extend... $1 $2"

}

trap 'extend pause 256' SIGRTMIN
trap 'rm -f /tmp/monitor.pid' EXIT
while true;do
time=$[$RANDOM%3+1]
echo "sleep $time"
sleep $time
extend time 128
done
