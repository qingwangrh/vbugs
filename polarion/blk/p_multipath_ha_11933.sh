#!/bin/sh
qemu-img create -f qcow2 /home/images/data1.qcow2 1G
qemu-img create -f qcow2 /home/images/data2.qcow2 2G
/usr/libexec/qemu-kvm \
  -name manual_vm1 \
  -machine pc \
  -nodefaults \
  -vga qxl \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.7-Server-x86_64.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -blockdev \
  driver=host_device,cache.direct=on,cache.no-flush=off,node-name=file_img1,filename=/dev/mapper/mpathb \
  -blockdev driver=raw,node-name=drive_img1,file=file_img1 \
  -device virtio-blk-pci,id=os1,drive=drive_img1,addr=0x03,werror=stop,rerror=stop \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,netdev=idxgXAlm,addr=0x8, \
  -netdev tap,id=idxgXAlm,vhost=on \
  -device qemu-xhci,id=usb1,addr=0x9 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1

test_steps() {
  echo

  multipathd fail path /dev/sdd
  multipath -l
  multipathd fail path /dev/sde
  multipath -l

  multipathd reinstate path /dev/sde
  multipath -l
}
