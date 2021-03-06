#!/bin/sh
qemu-img create -f qcow2 /home/images/data1.qcow2 1G

/usr/libexec/qemu-kvm \
  -name manual_vm1 \
  -machine pc \
  -nodefaults \
  -vga qxl \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi1,bus=pci.0,iothread=iothread0 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device virtio-blk-pci,id=os1,drive=drive_image1,bus=pci.0,bootindex=0 \
  \
  -blockdev driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data1.qcow2,node-name=protocol_node1 \
  -blockdev driver=qcow2,node-name=format_node1,file=protocol_node1 \
  -device virtio-blk-pci,id=blk_data1,drive=format_node1,bus=pci.0,bootindex=1 \
  -vnc \
  :5 \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0


test_steps(){
  echo
  repeat_add
  #only work on machine pc, for q35, it need to setup root_port first

}