#wqmp_exec() {
#  exec 3<>/dev/tcp/localhost/5955
#  echo "$@"
#  echo -e "{'execute':'qmp_capabilities'}" >&3
#  read response <&3
#  echo "$response"
#  echo "ready to execute"
#  echo -e "$@" >&3
#  read response <&3
#  echo "$response"
#
#}

wqmp_loop() {
  echo "wloop_qmp start end action"
  exec 3<>/dev/tcp/localhost/5955
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response

  unset n
  start=$1
  let end=$1+$2
  shift
  shift
  cmd="$@"
  # you need put ; for you multiline command
  cmd=$(echo $cmd | tr -s "\n" ";")
  echo $cmd

  for ((n = $start; n < $end; n++)); do
    echo ""
    #    echo "$(date)- - - - - - - - - - -$n"
    #replace @@ with index
    new_cmd="${cmd//@@/$n}"

    OLD_IFS="$IFS"
    IFS=";"

    myarray=($new_cmd)

    for mvar in ${myarray[@]}; do
      var=$(echo "$mvar" | grep -o "[^ ]\+\( \+[^ ]\+\)*")
      if [[ "x$var" != "x" ]]; then
        if echo "$var" | grep ":" >/dev/null; then
          echo "$var"
          echo -e "$var" >&3
          read response <&3
          echo "$response"
        else
          eval "$var"
        fi
      fi
    done
    IFS="$OLD_IFS"

    sleep 1

  done
}

wqmp_exec() {
  wqmp_loop 1 1 "$@"
}

#NUM_LUNS=40
#add_devices() {
#  exec 3<>/dev/tcp/localhost/5955
#  echo "$@"
#  echo -e "{'execute':'qmp_capabilities'}" >&3
#  read response <&3
#  echo $response
#  for i in $(seq 1 $NUM_LUNS); do
#    cmd="{'execute':'device_add', 'arguments': {'driver':'scsi-hd','drive':'test_disk$i','id':'scsi_disk$i','bus':'scsi1.0','lun':$i}}"
#    echo "$cmd"
#    echo -e "$cmd" >&3
#    read response <&3
#    echo "$response"
#  done
#}
#
#remove_devices() {
#  exec 3<>/dev/tcp/localhost/5955
#  echo "$@"
#  echo -e "{'execute':'qmp_capabilities'}" >&3
#  read response <&3
#  echo $response
#  for i in $(seq 1 $NUM_LUNS); do
#    cmd="{'execute':'device_del', 'arguments': {'id':'scsi_disk$i'}}"
#    echo "$cmd"
#    echo -e "$cmd" >&3
#    read response <&3
#    echo "$response"
#  done
#}

#while true ; do
#    echo "adding devices"
#    add_devices
#    sleep 3
#    echo "removing devices"
#    remove_devices
#    sleep 3
#done
