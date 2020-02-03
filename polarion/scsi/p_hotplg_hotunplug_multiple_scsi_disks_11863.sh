/usr/libexec/qemu-kvm \
  -name copy_read_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.8-Server-x86_64.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data3.qcow2,node-name=data_image1 \
  -device virtio-blk-pci,id=data1,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

  for i in `seq 0 19`;do qemu-img create -f qcow2 "/home/images/stg$i.qcow2" 1G;done
  for i in `seq 0 19`;do qemu-img create -f qcow2 "/home/kvm_autotest_root/images/stg$i.qcow2" 1G;done
  {"execute": "qmp_capabilities"}

  {"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"virtio_scsi_pci1","bus":"pcie.0-root-port-9","addr":"0x0"}}

  {"execute": "blockdev-add","arguments": {"node-name":"data_disk1","driver":"file","filename":"/home/kvm_autotest_root/images/stg1.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk1","driver":"qcow2","file":"data_disk1"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk1","id":"data_disk1","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk2","driver":"file","filename":"/home/kvm_autotest_root/images/stg2.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk2","driver":"qcow2","file":"data_disk2"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk2","id":"data_disk2","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk3","driver":"file","filename":"/home/kvm_autotest_root/images/stg3.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk3","driver":"qcow2","file":"data_disk3"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk3","id":"data_disk3","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk4","driver":"file","filename":"/home/kvm_autotest_root/images/stg4.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk4","driver":"qcow2","file":"data_disk4"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk4","id":"data_disk4","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk5","driver":"file","filename":"/home/kvm_autotest_root/images/stg5.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk5","driver":"qcow2","file":"data_disk5"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk5","id":"data_disk5","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk6","driver":"file","filename":"/home/kvm_autotest_root/images/stg6.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk6","driver":"qcow2","file":"data_disk6"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk6","id":"data_disk6","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk7","driver":"file","filename":"/home/kvm_autotest_root/images/stg7.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk7","driver":"qcow2","file":"data_disk7"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk7","id":"data_disk7","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk8","driver":"file","filename":"/home/kvm_autotest_root/images/stg8.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk8","driver":"qcow2","file":"data_disk8"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk8","id":"data_disk8","bus":"virtio_scsi_pci1.0"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk9","driver":"file","filename":"/home/kvm_autotest_root/images/stg9.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk9","driver":"qcow2","file":"data_disk9"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk9","id":"data_disk9","bus":"virtio_scsi_pci1.0"}}

{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"scsi1","bus":"pcie.0-root-port-8","addr":"0x0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive2"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive2","id":"data-disk1","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive3"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive3","id":"data-disk2","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive4"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive4","id":"data-disk3","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive5"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive5","id":"data-disk4","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive6"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive6","id":"data-disk5","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive7"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive7","id":"data-disk6","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive8"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive8","id":"data-disk7","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive9"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive9","id":"data-disk8","bus":"scsi1.0"}}
{"execute": "blockdev-add","arguments": {"driver": "null-co","node-name": "drive10"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive10","id":"data-disk9","bus":"scsi1.0"}}


{"execute":"device_del","arguments":{"id":"data_disk1"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk1"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk1"}}
{"execute":"device_del","arguments":{"id":"data_disk2"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk2"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk2"}}
{"execute":"device_del","arguments":{"id":"data_disk3"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk3"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk3"}}
{"execute":"device_del","arguments":{"id":"data_disk4"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk4"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk4"}}
{"execute":"device_del","arguments":{"id":"data_disk5"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk5"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk5"}}
{"execute":"device_del","arguments":{"id":"data_disk6"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk6"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk6"}}
{"execute":"device_del","arguments":{"id":"data_disk7"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk7"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk7"}}
{"execute":"device_del","arguments":{"id":"data_disk8"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk8"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk8"}}
{"execute":"device_del","arguments":{"id":"data_disk9"} }
{ "execute": "blockdev-del","arguments": { "node-name": "disk9"}}
{ "execute": "blockdev-del","arguments": { "node-name": "data_disk9"}}
{"execute":"device_del","arguments":{"id":"virtio_scsi_pci1"} }
##################################################
  #drive

  #{"execute":"__com.redhat_drive_add", "arguments": {"file":"/dev/sdb","format":"raw","id":"drive-scsi-disk1"}}

  {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive-scsi-disk1,if=none,snapshot=off,aio=native,cache=none,format=raw,file=/dev/sdd"}}

  {"execute":"__com.redhat_drive_add", "arguments": {"file":"data.raw","format":"raw","id":"drive-scsi-disk1"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"scsi1","num_queues":"4"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive-scsi-disk1","id":"scsi-disk1"}}

  {"execute":"__com.redhat_drive_add", "arguments": {"file":"data1.raw","format":"raw","id":"drive-virtio-disk0"}}
{"execute":"device_add","arguments":{"driver":"virtio-blk-pci","drive":"drive-virtio-disk0","id":"virtio-disk0"}}

  {"execute":"device_del","arguments":{"id":"scsi-disk1"}}
{"execute":"device_del","arguments":{"id":"scsi1"}}

{"execute":"device_del","arguments":{"id":"virtio-disk0"}}

}
