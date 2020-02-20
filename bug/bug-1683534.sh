do_pc(){
/usr/libexec/qemu-kvm \
        -name 'avocado-vt-vm1' \
        -machine pc \
        -nodefaults \
        -device VGA,bus=pci.0,addr=0x2 \
        -object iothread,id=iothread0 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
        -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,iothread=iothread0,bus=pci.0,addr=0x3 \
        -m 15360 \
        -smp 12,maxcpus=12,cores=6,threads=1,sockets=2 \
        \
        -device virtio-net-pci,mac=9a:31:32:33:34:35,id=idYxHDLn,vectors=4,netdev=idoOknQC,bus=pci.0,addr=0x4 \
        -netdev tap,id=idoOknQC,vhost=on \
        -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x5 \
        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
        -device scsi-cd,id=cd1,drive=drive_cd1,bootindex=1 \
        -device qemu-xhci,id=usb1,bus=pci.0,addr=0x6 \
        -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
        -vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:4446,server,nowait \
        -monitor stdio \

}

do_q35(){
/usr/libexec/qemu-kvm \
        -name 'avocado-vt-vm1' \
        -machine q35 \
        -nodefaults \
        -device VGA,bus=pcie.0,addr=0x1 \
        -object iothread,id=iothread0 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
        -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
        -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,iothread=iothread0,bus=pcie.0-root-port-3,addr=0x0 \
        -m 15360 \
        -smp 12,maxcpus=12,cores=6,threads=1,sockets=2 \
       \
        -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
        -device virtio-net-pci,mac=9a:31:32:33:34:35,id=idYxHDLn,vectors=4,netdev=idoOknQC,bus=pcie.0-root-port-4,addr=0x0 \
        -netdev tap,id=idoOknQC,vhost=on \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
        -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-5,addr=0x0 \
        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
        -device scsi-cd,id=cd1,drive=drive_cd1,bootindex=1 \
        -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
        -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
        -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
        -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
        -vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:4446,server,nowait \
        -monitor stdio \


}

do_pc

steps(){
{"execute": "qmp_capabilities"}

#q35
{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/storage0.qcow2"}, "id": "Yu6Mfcom"}

{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "iothread": "iothread0", "bus": "pcie_extra_root_port_0"}, "id": "t07OBwFH"}


D:\Iozone\iozone.exe -azR -r 64k -n 125M -g 512M -M -i 0 -i 1 -b E:\iozone_test -f E:\testfile

{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "XVosfhHr"}

#q35 should have two event,but only one event. pc looks like good
#for pc ok
    {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/storage0.qcow2"}, "id": "Yu6Mfcom"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "iothread": "iothread0", "bus": "pci.0", "addr": "0x8"}, "id": "0MFQJSVK"}

}