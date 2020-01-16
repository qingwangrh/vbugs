#!/bin/sh

#iscsiadm --mode node --targetname iqn.2016-06.qing.server:b --portal 10.66.8.105:3260 --login
#iscsiadm --mode node --targetname iqn.2016-06.qing.server:b --portal 10.66.8.105:3260 --login
/usr/libexec/qemu-kvm \
  -name manual_vm1 \
  -machine pc \
  -nodefaults \
  -vga qxl \
  -device qemu-xhci,id=usb1,addr=0x9 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device virtio-blk-pci,id=os1,drive=drive_image1,addr=0x3,bootindex=0 \
  \
  -blockdev driver=iscsi,cache.direct=on,cache.no-flush=off,node-name=protocol_node1,transport=tcp,portal=10.66.8.105,target=iqn.2016-06.local.server:sas,initiator-name=iqn.1994-05.com.redhat:dell-per740xd-01 \
  -blockdev driver=raw,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device virtio-blk-pci,id=data1,drive=drive-virtio-disk0,rerror=stop,werror=stop,addr=0x4,bootindex=1 \
  \
  -iscsi initiator-name=iqn.1994-05.com.redhat:dell-per740xd-01 \
  -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:a/0,if=none,id=drive-virtio-disk1,format=raw,cache=none \
  -device virtio-blk-pci,drive=drive-virtio-disk1,rerror=stop,werror=stop,addr=0x5,id=data2,bootindex=2  \
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,netdev=idxgXAlm,addr=0x8, \
  -netdev tap,id=idxgXAlm,vhost=on \

test_steps(){
  echo
  mkfs.ext4 /dev/vdb
  mkfs.ext4 /dev/vdc


}