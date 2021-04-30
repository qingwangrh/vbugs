#!/usr/bin/env bash

if lscpu |grep ^Vendor|grep AMD;then
	cpuflag=svm
else
	cpuflag=vmx
fi

/usr/libexec/qemu-kvm \
  -name ovirt-node \
  -machine q35 \
  -m 24G \
  -smp 8 \
  -cpu host,$cpuflag,+kvm_pv_unhalt \
  -device qemu-xhci,id=usb1 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x3,chassis=1 \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pcie.0,chassis=2 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=pcie.0,chassis=6 \
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=pcie.0,chassis=7 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=pcie.0,chassis=8  \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/ovirt-node.qcow2,node-name=drive_image1   \
  -device scsi-hd,id=os,drive=drive_image1,bus=scsi0.0,bootindex=0,serial=OS_DISK   \
  \
  -vnc :6 \
  -monitor stdio \
  -qmp tcp:0:5956,server,nowait \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b9,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie-root-port-7 \
  -netdev tap,id=idxgXAlm \
  -boot menu=on,reboot-timeout=1000 \
   \


steps(){
  -device virtio-net-pci,netdev=hostnet1,id=net1,mac=00:50:56:06:06:02 \
  -netdev tap,id=hostnet1,vhost=on,script=/etc/qemu-ifup-br0 \

}