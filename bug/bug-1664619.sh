qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G

pc(){
/usr/libexec/qemu-kvm \
       	-name 'test' \
       	-sandbox off \
       	-machine pc \
       	-nodefaults \
       	-device qxl-vga \
	-object iothread,id=iothread0 \
	-object iothread,id=iothread1 \
	-object iothread,id=iothread2 \
	-blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_win1,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2 \
	-blockdev driver=qcow2,node-name=drive_win1,file=file_win1 \
	-device virtio-blk-pci,id=image2,drive=drive_win1,iothread=iothread0 \
	-blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.qcow2 \
	-blockdev driver=qcow2,node-name=drive_stg1,file=file_stg1 \
	-device virtio-blk-pci,id=image3,drive=drive_stg1,iothread=iothread1,logical_block_size=8192,physical_block_size=8192 \
	-device virtio-net-pci,mac=6c:ae:8b:20:80:70,id=iddd,vectors=4,netdev=idttt \
	-netdev tap,id=idttt,vhost=on \
	-m 4G \
	-smp 12,maxcpus=12,cores=6,threads=1,sockets=2 \
	-cpu 'SandyBridge' \
	-device qemu-xhci,id=usb1 \
	-device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
	 -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}


q35(){
/usr/libexec/qemu-kvm \
    -name 'test-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -object iothread,id=iothread0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-3,addr=0x0,iothread=iothread0 \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-4,addr=0x0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,node-name=os_img \
    -blockdev driver=qcow2,node-name=os_drive,file=os_img \
    -device virtio-blk-pci,drive=os_drive,id=os_disk,bus=pcie.0-root-port-6 \
    \
    -blockdev driver=file,cache.direct=on,cache.no-flush=off,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.qcow2 \
    -blockdev driver=qcow2,node-name=drive_stg1,file=file_stg1 \
    -device virtio-blk-pci,drive=drive_stg1,id=data,bus=pcie.0-root-port-7,addr=0x0,iothread=iothread0,logical_block_size=8192,physical_block_size=8192 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 8G  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}

q35

steps() {
#windows guest is ok
#pc and q35 have same issue


    {"execute": "qmp_capabilities"}

}