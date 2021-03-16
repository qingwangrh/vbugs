target=$1

if [[ "x$target" == "x" ]]; then
  #src default
  target=
  echo "run as src"
else
  echo "run as dst"
  target=" -incoming defer "
fi

/usr/libexec/qemu-kvm \
  -name high_q35_vm \
  -machine pc-q35-rhel8.3.0 \
  -nodefaults \
  -vga qxl \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL8.4.0-BaseOS-x86_64.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-6,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,iothread=iothread0 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-5,iothread=iothread0 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/qing/images/rhel840-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/qing/images/data1.qcow2,node-name=data_image1,discard=ignore,read-only=off,lazy-refcounts=on,overlap-check=none,auto-read-only=on,force-share=off,file.aio=threads \
  -device virtio-blk-pci,id=blk_data1,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=on,cache.no-flush=on,file.filename=/home/qing/images/data2.qcow2,node-name=data_image2,discard=unmap,read-only=on,lazy-refcounts=off,overlap-check=none,auto-read-only=off,force-share=on,file.aio=native \
  -device scsi-hd,id=scsi_data2,drive=data_image2,bootindex=2 \
  -vnc :5 \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0 \
  $target

steps() {

  #host
  mkdir -p /home/qing/images
  mkdir -p /home/kvm_autotest_root/iso
  mount 10.73.194.27:/vol/s2kvmauto/iso  /home/kvm_autotest_root/iso

#  echo "/home/ *(rw,no_root_squash)">/etc/exports
#  systemctl restart nfs-server
  mount 10.66.8.105:/home/kvm_autotest_root/images /home/qing/images
  [[ ! -e /home/qing/images/data1.qcow2 ]] && qemu-img create -f qcow2 /home/qing/images/data1.qcow2 11G
  [[ ! -e /home/qing/images/data2.qcow2 ]] && qemu-img create -f qcow2 /home/qing/images/data2.qcow2 12G

  #dst
  {'execute': 'qmp_capabilities'}
  {'execute': 'migrate-incoming', 'arguments': {'uri': 'tcp:[::]:5000'}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"late-block-activate","state":true}]}}

  #src
  {'execute': 'qmp_capabilities'}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"pause-before-switchover","state":true}]}}
  {"execute": "migrate","arguments":{"uri": "tcp:10.73.196.177:5000"}}
  {"execute":"query-migrate"}
  {"execute":"migrate-continue","arguments":{"state":"pre-switchover"}}

  {"execute":"migrate-start-postcopy"}
  {"execute":"query-migrate"}

  #or hmp
  #dst
  migrate_incoming tcp:[::]:5000
  migrate_set_capability postcopy-ram on
  #src
  migrate_set_capability postcopy-ram on
  migrate -d tcp:10.73.224.209:5000
  migrate_start_postcopy

  10.73.196.177
}
