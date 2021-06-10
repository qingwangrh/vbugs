#!/usr/bin/env bash


qmp() {
  exec 3<>/dev/tcp/localhost/5955
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response

  local idx=0
  while true; do
    echo -e "{'execute':'query-status'}" >&3

    read response <&3
    while ! echo "$response" | grep status >/dev/null; do
      echo "reread:$response"
#      sleep 0.1
      read response <&3
    done

    if echo "$response" | grep io-error; then
      status=pause
      if [[ "$status" != "pause" ]];then
      status="pause"
      echo "pause"
      fi
      let idx++

      lvextend -L +2G /dev/vg/lv1 --resizefs
      lvchange --refresh vg/lv1
      lvs vg/lv1
      echo -e "{'execute':'cont'}" >&3
      read response <&3
#      sleep 3
    else
      if [[ "$status" != "running" ]];then
      status="running"
      echo "running"
      fi
      sleep 0.05
    fi

  done
}
qmp
