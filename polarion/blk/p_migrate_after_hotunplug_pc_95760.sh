#!/bin/sh
qemu-img create -f qcow2 /home/images/data1.qcow2 1G
qemu-img create -f qcow2 /home/images/data2.qcow2 2G
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
  -blockdev driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data1.qcow2,node-name=protocol_node1 \
  -blockdev driver=qcow2,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device virtio-blk-pci,id=data1,drive=drive-virtio-disk0,addr=0x4,bootindex=1 \
    \
  -drive file=/home/images/data2.qcow2,if=none,id=drive-virtio-disk1,format=qcow2,cache=none \
  -device virtio-blk-pci,scsi=off,drive=drive-virtio-disk1,addr=0x5,id=data2 \
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

  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.qcow2,node-name=drive-virtio-disk0 \
  -device virtio-blk-pci,id=data1,drive=drive-virtio-disk0,addr=0x4,bootindex=1 \
  \
  -blockdev driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data1.qcow2,node-name=protocol_node1 \
  -blockdev driver=qcow2,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device virtio-blk-pci,id=data1,drive=drive-virtio-disk0,addr=0x4,bootindex=1 \
  \
  -drive file=/home/images/data2.qcow2,if=none,id=drive-virtio-disk1,format=qcow2,cache=none \
  -device virtio-blk-pci,scsi=off,drive=drive-virtio-disk1,addr=0x5,id=data2 \

   {"execute": "qmp_capabilities"}
   #For blockdev usage:

   {"execute":"device_del", "arguments": {"id":"data1"}}
   {"execute":"blockdev-del","arguments":{"node-name":"drive-virtio-disk0"}}
    {"execute":"blockdev-del","arguments":{"node-name":"protocol_node1"}}
   #For drive usage:
   {"execute":"device_del","arguments":{"id":"data2"}}

   #(qemu) migrate_set_capability postcopy-ram on
   {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}

   {"execute": "migrate","arguments":{"uri": "tcp:0:5888"}}
   migrate_start_postcopy
   {"execute":"query-migrate"}
}