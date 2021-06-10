#!/usr/bin/env bash
#monitor the vm status

exec {fd1}<>/dev/tcp/localhost/5955
exec {fd2}<>/dev/tcp/localhost/5956
echo "fd:$fd1 $fd2"
for fd in $fd1 $fd2; do
  echo -e "{'execute':'qmp_capabilities'}" >&$fd
  read response <&$fd
done

echo "fd:$fd1 - $fd2"

echo "$$" >/tmp/monitor.pid
echo "$$"
trap 'get_status $fd2' SIGRTMIN
trap 'rm -f /tmp/monitor.pid' EXIT

get_status() {

  fd=$1
  echo "get_status:$fd"
  echo -e "{'execute':'query-status'}" >&$fd

  read response <&$fd
  while ! echo "$response" | grep status >/dev/null; do
    #read unexpected msg
    echo "getread:$response"
    read response <&$fd
  done
  time=$(date "+%M:%S")
  if echo "$response" | grep io-error; then
    echo "get $fd ==> :$time:pause"
  else
    echo "get $fd ==> :$time:running"

  fi

}




monitor() {


  local idx=0
  while true; do
    vm_status=$(get_status $fd1)


    if echo "$vm_status" | grep pause; then

      if [[ "$status" != "pause" ]]; then
        status="pause"
        echo "--> pause"
        #notify to extend
        if [[ -f /tmp/extend_lvm.pid ]]; then
          kill -SIGRTMIN $(cat /tmp/extend_lvm.pid)
          sleep 2
        fi
      fi
      let idx++
      echo -e "{'execute':'cont'}" >&$fd1
      read response <&$fd1
      #the vm will become to running if no sleep
      sleep 2
    else
#      echo "$vm_status"
      if [[ "$status" != "running" ]]; then
        status="running"
        echo "--> running"
      fi
      sleep 0.1
    fi

  done
}


monitor
