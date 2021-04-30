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
      sleep 0.1
      read response <&3
    done

    if echo "$response" | grep io-error; then

      let idx=idx+1


      if ((idx % 2 == 1));then
        lvdev=lv1
      else
        lvdev=lv3
      fi
      for lvdev in lv1 lv3;do
      echo "extend ${lvdev} $idx  $response"
      lvextend -An -L +64M /dev/vg/${lvdev}
#      lvextend -L +1G /dev/vg/${lvdev}
      lvchange --refresh vg/${lvdev}
      done
      lvs vg

      echo -e "{'execute':'cont'}" >&3
      read response <&3
#      sleep 0.1
    else
      echo "running"
      sleep 0.05
    fi

#    if (($idx > 95)); then
#      echo "over $idx"
#    fi

  done
}
qmp
