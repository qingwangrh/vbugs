
#there are on one server

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
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-domain-node1.qcow2,node-name=drive_image1 \
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
  -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet1 \
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
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-domain-node2.qcow2,node-name=drive_image1 \
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
  -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:56,bus=pcie.0-root-port-6,addr=0x0 \


#-device virtio-net-pci,mac=9a:b5:b6:b1:b2:b6,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
#  -netdev tap,id=idxgXAlm \
}

echo "ready fc run $1"
if [[ "X$1" == "X" ]];then
 echo "default vm1"
 vm1
else
 echo "vm2"
 vm2
fi

steps() {
######################
## ****run vms on one host
 systemctl start qemu-pr-helper
 systemctl status qemu-pr-helper
    # multipath -l

     -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
     -device virtio-scsi-pci,id=scsi-hotadd \
     -drive file=/dev/sdc,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-hotadd,serial=sas-test,file.pr-manager=helper0 \
      -device scsi-block,drive=drive-hotadd,bus=scsi-hotadd.0

    #register /release/read
    sg_persist -v -v --out --register-ignore --param-sark '0019469D7466734D' /dev/sdc
    sg_persist --out --register --param-rk=0x3edc9b807466734d /dev/sdc
    sg_persist --in --read-keys --device=/dev/sdc

}
