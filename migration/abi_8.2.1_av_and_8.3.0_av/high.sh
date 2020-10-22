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
  -name dst_vm \
  -machine  pc-q35-rhel8.2.0 \
  -nodefaults \
  -vga qxl \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso \
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
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/qing/images/rhel830-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/qing/images/data1.qcow2,node-name=data_image1 \
  -device virtio-blk-pci,id=blk_data1,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/qing/images/data2.qcow2,node-name=data_image2 \
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
  #yum install glusterfs-fuse -y
  mkdir -p /home/qing/images
  #mount qing:/home/kvm_autotest_root/images /home/qing/images
  mount.glusterfs gluster-virt-qe-01.lab.eng.pek2.redhat.com:/gv0/wq /home/qing/images
  [[ ! -e /home/qing/images/data1.qcow2 ]] && qemu-img create -f qcow2 /home/qing/images/data1.qcow2 1G
  [[ ! -e /home/qing/images/data2.qcow2 ]] && qemu-img create -f qcow2 /home/qing/images/data2.qcow2 2G

  #src and dst qemu
  migrate_set_capability postcopy-ram on

  #or #{"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}

  #dst
  {'execute': 'qmp_capabilities'}
  {'execute': 'migrate-incoming', 'arguments': {'uri': 'tcp:[::]:5000'}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"late-block-activate","state":true}]}}


  #src
  10.73.196.177
  10.73.224.209

  {'execute': 'qmp_capabilities'}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"postcopy-ram","state":true}]}}
  {"execute":"migrate-set-capabilities","arguments":{"capabilities":[{"capability":"pause-before-switchover","state":true}]}}
  {"execute": "migrate","arguments":{"uri": "tcp:10.73.196.177:5000"}}
  {"execute":"query-migrate"}
  {"execute":"migrate-continue","arguments":{"state":"pre-switchover"}}

  {"execute":"migrate-start-postcopy"}
  {"execute":"query-migrate"}

  #or
  #migrate tcp:10.73.114.30:5000

  migrate_start_postcopy
  #or
  {"execute":"migrate-start-postcopy"}
  {"execute":"query-migrate"}

}
