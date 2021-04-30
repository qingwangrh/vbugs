#!/usr/bin/env bash

if mount|grep /home/test;then
  qemu-img create -f qcow2 /home/test/stg5.qcow2 50G
  qemu-img create -f qcow2 /home/test/stg6.qcow2 50G
  qemu-img create -f qcow2 /home/test/stg7.qcow2 50G
  qemu-img create -f qcow2 /home/test/stg8.qcow2 50G
fi

/usr/libexec/qemu-kvm \
  -name guest=cw00067trotdb,debug-threads=on \
  -machine pc-i440fx-rhel7.6.0,accel=kvm,usb=off,dump-guest-core=off \
  -m 4G \
  -object iothread,id=iothread1 \
  -boot strict=on \
  -device piix3-usb-uhci,id=ua-efa5db52-c7a2-4a1a-9cf3-616f40b02bfc,bus=pci.0 \
  -blockdev \
  driver=file,filename=/home/kvm_autotest_root/images/rhel810-64-virtio.qcow2,node-name=my_file \
  -blockdev driver=qcow2,node-name=my,file=my_file \
  -device virtio-blk-pci,drive=my,id=virtio-blk0,bus=pci.0,bootindex=0 \
  \
  -blockdev driver=file,filename=/home/test/stg1.qcow2,aio=native,node-name=file1,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt1,read-only=off,cache.direct=on,cache.no-flush=off,file=file1 \
  -device virtio-blk-pci,bus=pci.0,drive=fmt1,id=data1,write-cache=on,werror=enospc \
  -blockdev driver=file,filename=/home/test/stg2.qcow2,aio=native,node-name=file2,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt2,read-only=off,cache.direct=on,cache.no-flush=off,file=file2 \
  -device virtio-blk-pci,bus=pci.0,drive=fmt2,id=data2,write-cache=on,werror=enospc \
  -blockdev driver=file,filename=/home/test/stg3.qcow2,aio=native,node-name=file3,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt3,read-only=off,cache.direct=on,cache.no-flush=off,file=file3 \
  -device virtio-blk-pci,bus=pci.0,drive=fmt3,id=data3,write-cache=on,werror=enospc \
  -blockdev driver=file,filename=/home/test/stg4.qcow2,aio=native,node-name=file4,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt4,read-only=off,cache.direct=on,cache.no-flush=off,file=file4 \
  -device virtio-blk-pci,bus=pci.0,drive=fmt4,id=data4,write-cache=on,werror=enospc \
  \
  -blockdev driver=file,filename=/home/test/stg5.qcow2,aio=native,node-name=file5,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt5,read-only=off,cache.direct=on,cache.no-flush=off,file=file5 \
  \
  -blockdev driver=file,filename=/home/test/stg6.qcow2,aio=native,node-name=file6,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt6,read-only=off,cache.direct=on,cache.no-flush=off,file=file6 \
  \
  -blockdev driver=file,filename=/home/test/stg7.qcow2,aio=native,node-name=file7,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt7,read-only=off,cache.direct=on,cache.no-flush=off,file=file7 \
  \
  -blockdev driver=file,filename=/home/test/stg8.qcow2,aio=native,node-name=file8,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt8,read-only=off,cache.direct=on,cache.no-flush=off,file=file8 \
  \
  -vnc :5 \
  -vga qxl \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait \
  -qmp tcp:0:5956,server,nowait \
  -usb -device usb-tablet \
  -device virtio-net-pci,netdev=nic1,id=vnet0,mac=54:43:00:1a:11:32 \
  -netdev tap,id=nic1,vhost=on

steps() {
wloop 1 8 qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg@@.qcow2 50G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 50G

{"execute": "qmp_capabilities"}
{"execute": "blockdev-snapshot", "arguments": {"node": "fmt1", "overlay": "fmt5"}}
{"execute": "blockdev-snapshot", "arguments": {"node": "fmt2", "overlay": "fmt6"}}
{"execute": "blockdev-snapshot", "arguments": {"node": "fmt3", "overlay": "fmt7"}}
{"execute": "blockdev-snapshot", "arguments": {"node": "fmt4", "overlay": "fmt8"}}


#100G
  dd if=/dev/urandom of=/dev/vdb bs=1M count=100000 oflag=direct

for i in {0001..6000} ; do dd if=/dev/urandom of=/home/test/file-$i.log bs=33M count=1 ; echo "$i"; done

}

