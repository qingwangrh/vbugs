
#qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
#qemu-img create -f qcow2 -b /home/kvm_autotest_root/images/rhel830-64-virtio.qcow2 -F qcow2 /home/kvm_autotest_root/images/scratch.img
#rm -rf /home/kvm_autotest_root/images/scratch.img


/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0 \
    \
    -object iothread,id=iothread0 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,write-cache=on,bus=pcie.0-root-port-3,iothread=iothread0 \
    \
    -blockdev node-name=data_image1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/stg1.qcow2,aio=threads \
    -blockdev node-name=data1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=data_image1 \
    -device virtio-blk-pci,id=disk1,drive=data1,write-cache=on,bus=pcie.0-root-port-7,iothread=iothread0 \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 4096  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \



steps(){
#run diskmanager->rescan or device management, do "Scan for hardware changed" in guest then do rescan

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 -b /home/kvm_autotest_root/images/rhel830-64-virtio.qcow2 -F qcow2 /home/kvm_autotest_root/images/scratch.img

qemu-img create -f qcow2 -b /home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2 -F qcow2 /home/kvm_autotest_root/images/scratch.img

{'execute':'qmp_capabilities'}
{"execute":"blockdev-add","arguments":{"driver":"qcow2","node-name":"tmp","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/scratch.img"},"backing":"drive_image1"}}


{"execute":"blockdev-add","arguments":{"driver":"qcow2","node-name":"tmp","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/scratch.img"},"backing":"drive_image1"}}

{'execute':'qmp_capabilities'}
{"execute":"device_del","arguments":{"id":"disk1"}}

}