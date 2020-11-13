NUM_LUNS=199

add_devices() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response
  for i in $(seq 1 $NUM_LUNS) ; do
  cmd="{'execute': 'blockdev-add', 'arguments': {'node-name': 'file_stg${i}', 'driver': 'file','filename': '/home/kvm_autotest_root/images/stg${i}.qcow2'}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  cmd="{'execute': 'blockdev-add', 'arguments': {'node-name': 'drive_stg${i}', 'driver': 'qcow2', 'file': 'file_stg${i}'}} "
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  cmd="{'execute': 'device_add', 'arguments': {'id': 'virtio_scsi_pci${i}', 'driver': 'virtio-scsi-pci', 'bus':'pcie_extra_root_port_${i}','addr':'0x0'}}"
  #cmd="{'execute': 'device_add', 'arguments': {'id': 'virtio_scsi_pci${i}', 'driver': 'virtio-scsi-pci', 'bus':'pcie_extra_root_port_${i}','addr':'0x0', 'iothread':'iothread1'}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  cmd="{'execute': 'device_add', 'arguments':{'driver':'scsi-hd', 'id':'stg${i}', 'bus':'virtio_scsi_pci${i}.0', 'drive':'drive_stg${i}'}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  sleep 0.3

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

add_devices
