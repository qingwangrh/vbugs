string="
{'execute': 'blockdev-add', 'arguments': {'node-name': 'file_stg@@', 'driver': 'file','filename': '/home/kvm_autotest_root/images/stg@@.qcow2' }}
{'execute': 'blockdev-add', 'arguments': {'node-name': 'drive_stg@@', 'driver': 'qcow2', 'file': 'file_stg@@'}};
{'execute': 'device_add', 'arguments': {'id': 'virtio_scsi_pci@@', 'driver': 'virtio-scsi-pci', 'bus':'pcie_extra_root_port_@@','addr':'0x0', 'iothread':'iothread1'}}
{'execute': 'device_add', 'arguments':{'driver':'scsi-hd', 'id':'stg@@', 'bus':'virtio_scsi_pci@@.0', 'drive':'drive_stg@@'}}
"
OLD_IFS="$IFS"
IFS=";"
string=$(echo $string | tr "\n" ";")
myarray=($string)

for mvar in ${myarray[@]}; do
  var=$(echo "$mvar" | grep -o "[^ ]\+\( \+[^ ]\+\)*")
  if [[ "x$var" != "x" ]]; then
    if echo "$var" | grep ":" >/dev/null; then
      echo "2-> $var"
    else
      echo "var"
    fi
  fi
done
IFS="$OLD_IFS"
