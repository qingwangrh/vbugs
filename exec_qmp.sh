

exec_qmp() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response

  echo -e "$@" >&3
  read response <&3
  echo "$response"

}


NUM_LUNS=40
add_devices() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response
  for i in $(seq 1 $NUM_LUNS) ; do
  cmd="{'execute':'device_add', 'arguments': {'driver':'scsi-hd','drive':'test_disk$i','id':'scsi_disk$i','bus':'scsi1.0','lun':$i}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  done
}

remove_devices() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response
  for i in $(seq 1 $NUM_LUNS) ; do
  cmd="{'execute':'device_del', 'arguments': {'id':'scsi_disk$i'}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  done
}


#while true ; do
#    echo "adding devices"
#    add_devices
#    sleep 3
#    echo "removing devices"
#    remove_devices
#    sleep 3
#done