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
    while ! echo "$response" | grep status; do
      echo "reread"
      sleep 1
      read response <&3
    done

    if echo "$response" | grep io-error; then

      let idx++
      echo "$idx $response"

      lvextend -L +1G /dev/vg/lv1
      lvchange --refresh vg/lv1
      lvs vg/lv1
      echo -e "{'execute':'cont'}" >&3
      read response <&3
      sleep 3
    else
      echo "running"
      sleep 2
    fi

    if (($idx > 95)); then
      echo "over $idx"
    fi

  done
}
qmp
