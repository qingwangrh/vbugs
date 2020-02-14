

vm1(){
/usr/libexec/qemu-kvm -name server1 \
 -M pc -enable-kvm -m 2G -smp 4 \
 -uuid ea78071a-f6e4-4347-8077-9cb9f7959e88 \
 -boot order=cd,menu=on \
-device qemu-xhci,id=usb1,bus=pci.0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
 -drive file=/home/images/win2019-64-virtio-scsi.qcow2,if=none,id=drive-ide0-0-0,format=qcow2,cache=none \
 -device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 \
 -vnc :5 \
 -monitor stdio \
 -qmp tcp:0:4444,server,nowait \
 -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet0 \
 -device e1000,netdev=hostnet0,id=net0,mac=00:52:5a:30:4e:60,bus=pci.0 \
 -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet2 \
 -device e1000,netdev=hostnet2,id=net2,mac=00:52:5a:30:4e:62,bus=pci.0 \
 -device virtio-scsi-pci,id=scsi-hotadd \
 -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:5g/0,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-hotadd \
 -device scsi-block,drive=drive-hotadd,bus=scsi-hotadd.0

}
 #-device ide-drive,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0
#-device scsi-hd,drive=drive-ide0-0-0,id=ide0-0-0,bus=scsi0.0 \
vm2(){
/usr/libexec/qemu-kvm -name server2 \
 -M pc -enable-kvm -m 2G -smp 4 \
 -uuid ea78071a-f6e4-4347-8077-9cb9f7959e66 \
 -boot order=cd,menu=on \
  -device qemu-xhci,id=usb1,bus=pci.0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
 -drive file=/home/images/win2019-2.qcow2,if=none,id=drive-ide0-0-0,format=qcow2,cache=none \
 -device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 \
 -vnc :6 \
 -monitor stdio \
 -qmp tcp:0:4446,server,nowait \
 -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet0 \
 -device e1000,netdev=hostnet0,id=net0,mac=00:52:5a:30:4e:50,bus=pci.0 \
 -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet2 \
 -device e1000,netdev=hostnet2,id=net2,mac=00:52:5a:30:4e:52,bus=pci.0 \
 -device virtio-scsi-pci,id=scsi-hotadd \
 -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:5g/0,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-hotadd \
 -device scsi-block,drive=drive-hotadd,bus=scsi-hotadd.0

}


vm3(){

/usr/libexec/qemu-kvm \
  -name src_vm1 \
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
    -uuid ea78071a-f6e4-4347-8077-9cb9f7959e66 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,bus=scsi0.0,drive=drive_image1,bootindex=0 \
  \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
\
    -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:5g/0,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-virtio-disk1 \
    -device scsi-block,bus=scsi1.0,id=data1,drive=drive-virtio-disk1,rerror=stop,werror=stop,bootindex=2 \
    \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:55,bus=pcie.0-root-port-6,addr=0x0 \

}

vm4(){

/usr/libexec/qemu-kvm \
  -name src_vm2 \
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
  -uuid ea78071a-f6e4-4347-8077-9cb9f7959e88 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,bus=scsi0.0,drive=drive_image1,bootindex=0 \
  \
-device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
\
    -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:5g/0,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-virtio-disk1 \
    -device scsi-block,bus=scsi1.0,id=data1,drive=drive-virtio-disk1,rerror=stop,werror=stop,bootindex=2 \
    \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b6,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet1 \
  -device e1000,netdev=hostnet1,id=net1,mac=00:1a:4a:12:13:56,bus=pcie.0-root-port-6,addr=0x0 \



}

echo "ready libiscsi run $1"
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
    # pr-manager=helper0, ? not support in libiscsi -> yes

#target server
    iqn.2008-11.org.linux-kvm:ea78071a-f6e4-4347-8077-9cb9f7959e66
    iqn.2008-11.org.linux-kvm:ea78071a-f6e4-4347-8077-9cb9f7959e88

    -blockdev driver=iscsi,cache.direct=on,cache.no-flush=off,node-name=protocol_node1,transport=tcp,portal=10.66.8.105,target=iqn.2016-06.local.server:sas,initiator-name=iqn.1994-05.com.redhat:user2 \
  -blockdev driver=raw,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device scsi-block,bus=scsi1.0,id=data1,drive=drive-virtio-disk0,rerror=stop,werror=stop,bootindex=2 \

    -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.local.server:sas/0,if=none,media=disk,format=raw,rerror=stop,werror=stop,readonly=off,aio=threads,cache=none,cache.direct=on,id=drive-virtio-disk1 \
    -device scsi-block,bus=scsi1.0,id=data1,drive=drive-virtio-disk1,rerror=stop,werror=stop,bootindex=2 \

#other hosts

    iscsiadm -m discovery -t sendtargets -p 10.66.8.105:3260
    iscsiadm -m node -T iqn.2016-06.qing.server:5g -p 10.66.8.105 --login
    #test
    #register /release/read
    sg_persist -v -v --out --register-ignore --param-sark '0019469D7466734D' /dev/sdc
    sg_persist --out --register --param-rk=0x3edc9b807466734d /dev/sdc
    sg_persist --in --read-keys --device=/dev/sdc

}
