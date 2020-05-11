/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -object iothread,id=iothread0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device virtio-scsi-pci,id=virtio_scsi_pci,iothread=iothread0,bus=pcie.0-root-port-3,addr=0x0 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:ab:fa:09:62:1c,id=idLVRSKI,netdev=idfMN0PL,bus=pcie.0-root-port-4,addr=0x0  \
    -netdev tap,id=idfMN0PL,vhost=on \
    -m 8G  \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :6  \
    -qmp tcp:0:5956,server,nowait \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -blockdev node-name=file_stg1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg1 \
    -blockdev node-name=file_stg2,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg2 \
    \
    -blockdev node-name=file_stg3,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg3.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg3,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg3 \
    -blockdev node-name=file_stg4,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg4.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg4,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg4 \
    \
    -blockdev node-name=file_stg5,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg5.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg5,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg5 \
    -blockdev node-name=file_stg6,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg6.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg6,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg6 \
    \
    -blockdev node-name=file_stg7,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg7.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg7,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg7 \
    -blockdev node-name=file_stg8,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg8.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg8,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg8 \
    \
    -device pcie-root-port,id=pcie_port_1,slot=5,chassis=5,addr=0x5,bus=pcie.0,hotplug=off \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bus=pcie_port_1,addr=0x0 \
    \
    -device pcie-root-port,id=pcie_port_2,slot=6,chassis=6,addr=0x6,bus=pcie.0,hotplug=on \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,bus=pcie_port_2,addr=0x0 \
    \
    -device pcie-root-port,id=pcie_port_3,slot=7,chassis=7,addr=0x7,bus=pcie.0,hotplug=off \
    -device pcie-root-port,id=pcie_port_4,slot=8,chassis=8,addr=0x8,bus=pcie.0,hotplug=on \


steps(){
echo

#host
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg5.qcow2 5G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg6.qcow2 6G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 7G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg8.qcow2 8G
#qmp

#case 1 does allow hotplug disk under
{"execute":"qmp_capabilities"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg3", "drive": "drive_stg3", "bus": "pcie_port_3"}, "id": "t07OBwF3"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg4", "drive": "drive_stg4", "bus": "pcie_port_4"}, "id": "t07OBwF4"}

{"execute":"query-block"}

{"execute":"query-pci"}

#######################################
{"execute":"qmp_capabilities"}

{"execute": "device_del", "arguments": {"id": "stg1"}, "id": "XVosfhH1"}
{"execute": "device_del", "arguments": {"id": "stg2"}, "id": "XVosfhH2"}

{"execute": "device_del", "arguments": {"id": "stg3"}, "id": "XVosfhH3"}
{"execute": "device_del", "arguments": {"id": "stg4"}, "id": "XVosfhH4"}

{"execute": "device_del", "arguments": {"id": "stg5"}, "id": "XVosfhH5"}
{"execute": "device_del", "arguments": {"id": "stg6"}, "id": "XVosfhH6"}

{"execute": "device_del", "arguments": {"id": "stg7"}, "id": "XVosfhH7"}
{"execute": "device_del", "arguments": {"id": "stg8"}, "id": "XVosfhH8"}


##############################
#not work on q35
{"id": "XVosfhH1", "error": {"class": "GenericError", "desc": "Bus 'pcie.0' does not support hotplugging"}

#hotunplug pcie_port_x with hotplug=off
{"execute": "device_del", "arguments": {"id": "pcie_port_1"}, "id": "XVosfhH1"}
{"execute": "device_del", "arguments": {"id": "pcie_port_2"}, "id": "XVosfhH2"}

{"execute": "device_del", "arguments": {"id": "pcie_port_3"}, "id": "XVosfhH3"}
{"execute": "device_del", "arguments": {"id": "pcie_port_4"}, "id": "XVosfhH4"}


#hotplug pcie_port_x with hotplug=off

}
