

vm1(){
/usr/libexec/qemu-kvm -name node1 \
 -M pc -enable-kvm -m 2G -smp 4 \
 -uuid ea78071a-f6e4-4347-8077-9cb9f7959e88 \
 -boot order=cd,menu=on \
-device qemu-xhci,id=usb1,bus=pci.0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
 -drive file=/home/windbg/win2019-node1.qcow2,if=none,id=drive-ide0-0-0,format=qcow2,cache=none \
 -device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 \
 -drive file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso,media=cdrom,id=cdrom,if=none \
 -device ide-cd,drive=cdrom,bootindex=1 \
 -vnc :5 \
 -monitor stdio \
 -qmp tcp:0:5955,server,nowait \
 -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet0 \
 -device e1000,netdev=hostnet0,id=net0,mac=00:52:5a:30:4e:60,bus=pci.0 \
 -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet2 \
 -device e1000,netdev=hostnet2,id=net2,mac=00:52:5a:30:4e:62,bus=pci.0 \
 -device virtio-scsi-pci,id=scsi1 \
 -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -blockdev driver=raw,file.driver=host_device,cache.direct=off,cache.no-flush=on,file.filename=/dev/sde,node-name=drive2,file.pr-manager=helper0 \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=0,drive=drive2,id=scsi0-0-0-0,bootindex=2 \
  \

}
 #-device ide-drive,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0
#-device scsi-hd,drive=drive-ide0-0-0,id=ide0-0-0,bus=scsi0.0 \
vm2(){
/usr/libexec/qemu-kvm -name node2 \
 -M pc -enable-kvm -m 2G -smp 4 \
 -uuid ea78071a-f6e4-4347-8077-9cb9f7959e66 \
 -boot order=cd,menu=on \
  -device qemu-xhci,id=usb1,bus=pci.0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
 -drive file=/home/windbg/win2019-node2.qcow2,if=none,id=drive-ide0-0-0,format=qcow2,cache=none \
 -device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0 \
 -drive file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso,media=cdrom,id=cdrom,if=none \
 -device ide-cd,drive=cdrom,bootindex=1 \
    -vnc :6 \
 -monitor stdio \
 -qmp tcp:0:5956,server,nowait \
 -netdev tap,script=/etc/qemu-ifup,downscript=no,id=hostnet0 \
 -device e1000,netdev=hostnet0,id=net0,mac=00:52:5a:30:4e:50,bus=pci.0 \
 -netdev tap,script=/etc/qemu-ifup1,downscript=no,id=hostnet2 \
 -device e1000,netdev=hostnet2,id=net2,mac=00:52:5a:30:4e:52,bus=pci.0 \
 -device virtio-scsi-pci,id=scsi1 \
 -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -blockdev driver=raw,file.driver=host_device,cache.direct=off,cache.no-flush=on,file.filename=/dev/sdf,node-name=drive2,file.pr-manager=helper0 \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=0,drive=drive2,id=scsi0-0-0-0,bootindex=3 \
  \

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

    online disk in 2 guest

#target server
    iqn.2008-11.org.linux-kvm:ea78071a-f6e4-4347-8077-9cb9f7959e66
    iqn.2008-11.org.linux-kvm:ea78071a-f6e4-4347-8077-9cb9f7959e88
    #uuid is part of initiname in windows

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
    sg_persist -v -v --out --register-ignore --param-sark '0019469D7466734D' /dev/sdg
    sg_persist --out --register --param-rk=0x3edc9b807466734d /dev/sdg
    sg_persist --in --read-keys --device=/dev/sdg

}
