#should test with windows guest
os=rhel79-64-virtio-scsi.qcow2
os=win2019-64-virtio-scsi.qcow2
vm1(){

/usr/libexec/qemu-kvm \
  -name wqvm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -drive id=drive_cd2,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
 -device ide-cd,id=cd2,drive=drive_cd2,bus=ide.1,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/${os},node-name=drive_image1 \
  -device scsi-hd,id=os1,bus=scsi0.0,drive=drive_image1,bootindex=0 \
  \
  -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev driver=raw,file.driver=host_device,cache.direct=off,cache.no-flush=on,file.filename=/dev/sdb,node-name=drive2,file.pr-manager=helper0 \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=0,drive=drive2,id=scsi0-0-0-0,bootindex=2 \
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  \
  -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:55,bus=pcie.0-root-port-6,addr=0x0 \

#-device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
#  -netdev tap,id=idxgXAlm \

}

vm2(){

/usr/libexec/qemu-kvm \
  -name wqvm2 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -drive id=drive_cd2,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
 -device ide-cd,id=cd2,drive=drive_cd2,bus=ide.1,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/2-${os},node-name=drive_image1 \
  -device scsi-hd,id=os1,bus=scsi0.0,drive=drive_image1,bootindex=0 \
  \
  -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev driver=raw,file.driver=host_device,cache.direct=off,cache.no-flush=on,file.filename=/dev/sdc,node-name=drive2,file.pr-manager=helper0 \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=0,drive=drive2,id=scsi0-0-0-0,bootindex=2 \
  \
  -vnc :6 \
  -qmp tcp:0:5956,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  \
  -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:56,bus=pcie.0-root-port-6,addr=0x0 \

#-netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet1 \
#-device virtio-net-pci,mac=9a:b5:b6:b1:b2:b6,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
#  -netdev tap,id=idxgXAlm \

}


vm3(){

/usr/libexec/qemu-kvm \
  -name wqvm3 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/3-${os},node-name=drive_image1 \
  -device scsi-hd,id=os1,bus=scsi0.0,drive=drive_image1,bootindex=0 \
  \
  -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev driver=raw,file.driver=host_device,cache.direct=off,cache.no-flush=on,file.filename=/dev/mapper/mpatha,node-name=drive2,file.pr-manager=helper0 \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=0,drive=drive2,id=scsi0-0-0-0,bootindex=2 \
  \
  -vnc :7 \
  -qmp tcp:0:5957,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  \
  -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:57,bus=pcie.0-root-port-6,addr=0x0 \

#-device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
#  -netdev tap,id=idxgXAlm \

}

echo "ready iscsi run $1"
if [[ "X$1" == "X" ]];then
 echo "default vm1 (5)"
 vm1
else
 echo "$@"
 $@
fi

steps() {
######################
## ****run vms on one host
 systemctl start qemu-pr-helper
 systemctl status qemu-pr-helper

  mkdir rpm;cd rpm
  brew download-build --debuginfo --arch=x86_64 qemu-kvm-rhev-2.12.0-44.el7_8.2
  yum install * -y
  yum install -y iscsi-initiator-utils  device-mapper*

  sh test-persist.sh /dev/sdb "(where sdb is the disk under test)"

cat test-persist.sh
#! /bin/sh
echo "sg_persist $@"

echo "1:register-key"
sg_persist --no-inquiry -v --out --register-ignore --param-sark 123aaa "$@"
echo "2:read-key"
sg_persist --no-inquiry --in -k "$@"
echo "3:reserve"
sg_persist --no-inquiry -v --out --reserve --param-rk 123aaa --prout-type 5 "$@"
echo "4:read-reservation"
sg_persist --no-inquiry --in -r "$@"
echo "5:release"
sg_persist --no-inquiry -v --out --release --param-rk 123aaa --prout-type 5 "$@"
echo "6:read-reservation"
sg_persist --no-inquiry --in -r "$@"
echo "7:cancel-register"
sg_persist --no-inquiry -v --out --register --param-rk 123aaa --prout-type 5 "$@"
echo "8:read-key"
sg_persist --no-inquiry --in -k "$@"



./test-persist.sh /dev/sdb
./test-persist.sh /dev/sdc
./test-persist.sh /dev/mapper/mpatha


}