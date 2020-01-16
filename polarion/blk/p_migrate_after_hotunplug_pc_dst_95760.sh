#!/bin/sh
/usr/libexec/qemu-kvm \
  -name manual_vm1 \
  -machine pc \
  -nodefaults \
  -vga qxl \
  \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device virtio-blk-pci,id=os1,drive=drive_image1,addr=0x3,bootindex=0 \
  \
   \
  \
  -vnc :6 \
  -qmp tcp:0:5956,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,netdev=idxgXAlm,addr=0x8 \
  -netdev tap,id=idxgXAlm,vhost=on \
  -incoming tcp:0:5888


test_steps(){
  echo

   {"execute": "qmp_capabilities"}
   #For blockdev usage:

   {"execute":"device_del", "arguments": {"id":"data1"}}
   {"execute":"blockdev-del","arguments":{"node-name":"drive-virtio-disk0"}}

   #For drive usage:
   {"execute":"device_del","arguments":{"id":"data2"}}
}