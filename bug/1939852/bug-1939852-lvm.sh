#!/usr/bin/env bash

/usr/libexec/qemu-kvm \
  -name guest=cw00067trotdb,debug-threads=on \
  -machine pc-i440fx-rhel7.6.0,accel=kvm,usb=off,dump-guest-core=off \
  -m 4G \
  -object iothread,id=iothread1 \
  -boot strict=on \
  -device piix3-usb-uhci,id=ua-efa5db52-c7a2-4a1a-9cf3-616f40b02bfc,bus=pci.0 \
  -blockdev \
  driver=file,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=my_file \
  -blockdev driver=qcow2,node-name=my,file=my_file \
  -device virtio-blk-pci,drive=my,id=virtio-blk0,bus=pci.0,bootindex=0 \
  \
  \
  -blockdev driver=host_device,filename=/dev/vg/lv1,node-name=file1 \
  -blockdev driver=raw,node-name=fmt1,file=file1 \
  -device virtio-blk-pci,iothread=iothread1,bus=pci.0,drive=fmt1,id=data1,write-cache=on,werror=stop \
  \
  -vnc \
  :5 \
  -vga qxl \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait \
  -qmp tcp:0:5956,server,nowait \
  -usb -device usb-tablet \
  -device virtio-net-pci,netdev=nic1,id=vnet0,mac=54:43:00:1a:11:32 \
  -netdev tap,id=nic1,vhost=on

steps() {

  -blockdev driver=host_device,filename=/dev/vg/lv1,aio=native,node-name=file1,cache.direct=on,cache.no-flush=off,auto-read-only=off,discard=unmap \
  -blockdev driver=qcow2,node-name=fmt1,read-only=off,cache.direct=on,cache.no-flush=off,file=file1 \
  -device virtio-blk-pci,iothread=iothread1,bus=pci.0,drive=fmt1,id=data1,write-cache=on,werror=enospc \

  modprobe -r scsi_debug
  modprobe scsi_debug add_host=1 sector_size=512 dev_size_mb=5120
  dev=$(lsscsi | grep scsi | awk '{ print $6 }')
  pvcreate ${dev}
  vgcreate vg ${dev}
  lvcreate -L 100M -n lv1 vg
  lvcreate -L 100M -n lv2 vg
  dev=/dev/vg/lv1
  qemu-img create -f qcow2 /dev/vg/lv1 1G

  qemu-img create -f qcow2 /dev/vg/lv2 100G
  qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2

  lvextend -L +100M  /dev/vg/lv1;lvchange --refresh vg/lv1;lvs vg/lv1
  lvextend -L +1000M  /dev/vg/lv1;lvchange --refresh vg/lv1;lvs vg/lv1

  lvremove vg/lv1 vg/lv2 -y;vgremove vg -y;
  pvremove /dev/loop1;losetup -d /dev/loop1

  qemu-img create -f raw /home/lvm.img 110G
  losetup /dev/loop1 /home/lvm.img
  pvcreate /dev/loop1
  vgcreate vg /dev/loop1
  lvcreate -L 100M -n lv1 vg
  lvcreate -L 100M -n lv2 vg

  qemu-img create -f qcow2 /dev/vg/lv2 100G
  qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2

#100G
  dd if=/dev/urandom of=/dev/vdb bs=1M count=100000 oflag=direct

}

