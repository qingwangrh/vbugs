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
  -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/mapper/mpatha \
  -blockdev driver=raw,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device virtio-blk-pci,id=data1,drive=drive-virtio-disk0,scsi=on,disable-modern=on,rerror=stop,werror=stop,addr=0x4,bootindex=1 \
  \
  -drive file=/dev/sde,if=none,id=drive-virtio-disk1,format=raw,cache=none \
  -device virtio-blk-pci,drive=drive-virtio-disk1,scsi=on,disable-modern=on,rerror=stop,werror=stop,addr=0x5,id=data2 \
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

  sg_inq /dev/mapper/mpatha

  Fafailed step3 . scsi=on still on support ?
https://bugzilla.redhat.com/show_bug.cgi?id=1629539

Fam Zheng 2018-09-18 01:25:22 UTC
RED HAT CONFIDENTIAL
Modern virtio has dropped scsi feature of virtio-blk, which mean sg_utils are not usable on virtio-blk devices in guest. Where is this test scenario from?


This case should be inactive?

[root@bootp-73-226-181 ~]# sg_inq /dev/vdb

sg_inq failed: Inappropriate ioctl for device


}