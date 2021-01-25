#!/usr/bin/env bash

#qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg1.qcow2 11G
#qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg2.qcow2 12G
#qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg3.qcow2 13G
#qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg4.qcow2 14G
#
#attr1=$1
#if  [[ "x$attr1" == "x" ]];then
#  attr1="x-iops-total=50,x-iops-total-max=100,x-iops-total-max-length=20 "
#fi

attr1="x-iops-total=50,x-iops-total-max=100,x-iops-total-max-length=20 "

os="rhel840-64-virtio-scsi.qcow2"
os="win2019-64-virtio-scsi.qcow2"
target=$1

if [[ "x$target" == "x" ]]; then
  #src default
  target=
  echo "run as src"
else
  echo "run as dst"
  target=" -incoming defer "
fi

pc() {

  /usr/libexec/qemu-kvm \
    -name 'pc-vm1' \
    -sandbox on \
    -machine pc \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 4096 \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2 \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,id=group1,$attr1 \
    -object throttle-group,id=group2,x-iops-total=50 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images1/${os},cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -blockdev \
    node-name=file_stg1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images1/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg1,driver=qcow2,file=file_stg1,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=qcow2_stg1 \
    -device scsi-hd,id=stg1,drive=drive_stg1,write-cache=on,serial=TARGET_DISK1 \
    -blockdev \
    node-name=file_stg2,driver=file,aio=threads,filename=/home/kvm_autotest_root/images1/stg2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg2,driver=qcow2,file=file_stg2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=throttle,throttle-group=group2,file=qcow2_stg2 \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,write-cache=on,serial=TARGET_DISK2 \
    -device \
    virtio-net-pci,mac=9a:c0:0c:1b:16:0f,id=idwi9T4y,netdev=idO0GYFF,bus=pci.0,addr=0x6 \
    -netdev tap,id=idO0GYFF,vhost=on \
    -vnc :5 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    $target

}

q35() {

  /usr/libexec/qemu-kvm \
    -name "q35-vm" \
    -sandbox off \
    -machine q35 \
    -cpu Skylake-Client \
    -nodefaults \
    -vga std \
    -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpmonitor1,server,nowait \
    -chardev socket,id=qmp_id_catch_monitor,path=/var/tmp/monitor-catch_monitor,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control \
    -mon chardev=qmp_id_catch_monitor,mode=control \
    -device pcie-root-port,port=0x10,chassis=1,id=root0,bus=pcie.0,multifunction=on,addr=0x2 \
    -device pcie-root-port,port=0x11,chassis=2,id=root1,bus=pcie.0,addr=0x2.0x1 \
    -device pcie-root-port,port=0x12,chassis=3,id=root2,bus=pcie.0,addr=0x2.0x2 \
    -device pcie-root-port,port=0x13,chassis=4,id=root3,bus=pcie.0,addr=0x2.0x3 \
    -device pcie-root-port,port=0x14,chassis=5,id=root4,bus=pcie.0,addr=0x2.0x4 \
    -device pcie-root-port,port=0x15,chassis=6,id=root5,bus=pcie.0,addr=0x2.0x5 \
    -device pcie-root-port,port=0x16,chassis=7,id=root6,bus=pcie.0,addr=0x2.0x6 \
    -device pcie-root-port,port=0x17,chassis=8,id=root7,bus=pcie.0,addr=0x2.0x7 \
    -device nec-usb-xhci,id=usb1,bus=root0 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=root1 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images1/${os},node-name=drive_sys1 \
    -blockdev driver=qcow2,node-name=drive_image1,file=drive_sys1 \
    -device scsi-hd,id=image1,drive=drive_image1,bus=virtio_scsi_pci0.0,channel=0,scsi-id=0,lun=0,bootindex=0 \
    -object throttle-group,id=group1,x-iops-total=50,x-iops-total-max=100,x-iops-total-max-length=20 \
    -blockdev node-name=file_stg1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images1/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg1,driver=qcow2,file=file_stg1,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=qcow2_stg1 \
    -device scsi-hd,id=stg1,drive=drive_stg1,write-cache=on,serial=TARGET_DISK1,bus=virtio_scsi_pci0.0 \
    -device virtio-net-pci,mac=9a:8a:8b:8c:8d:8e,id=net0,vectors=4,netdev=tap0,bus=root2 \
    -netdev tap,id=tap0,vhost=on \
    -m 4096 \
    -smp 4,maxcpus=4,cores=2,threads=1,sockets=2 \
    -vnc :5 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    ${target}

}

q35

steps() {

  qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg1.qcow2 11G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg2.qcow2 12G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg3.qcow2 13G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images1/stg4.qcow2 14G

  #host1 (src)
  cat /etc/exports
  #/home/kvm_autotest_root/images *(rw,no_root_squash)
  systemctl restart nfs-server
  mkdir -p /home/kvm_autotest_root/images1
  mount dell8:/home/kvm_autotest_root/images /home/kvm_autotest_root/images1

  {"execute":"qmp_capabilities"}
  {'execute': 'qom-get', 'arguments': {'path': 'group1', 'property': 'limits'}}

  #dst dell10
  {'execute': 'qmp_capabilities'}
  {'execute': 'migrate-incoming', 'arguments': {'uri': 'tcp:[::]:5000'}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}

  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"late-block-activate","state":true}]}}

  #hmp
  migrate_incoming tcp:[::]:1234
  #src

  {'execute': 'qmp_capabilities'}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}

  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"pause-before-switchover","state":true}]}}
  {"execute": "migrate","arguments":{"uri": "tcp:10.73.114.30:5000"}}
  {"execute":"query-migrate"}
  {"execute":"migrate-continue","arguments":{"state":"pre-switchover"}}

  {"execute":"migrate-start-postcopy"}
  {"execute":"query-migrate"}

  migrate -d tcp:10.73.196.25:1234

}
