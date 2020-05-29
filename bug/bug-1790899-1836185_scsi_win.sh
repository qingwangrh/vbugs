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
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2 \
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
    -device virtio-scsi-pci,id=scsi1,bus=pcie_port_1,addr=0x0,hotplug=off \
    -device scsi-hd,id=stg1,drive=drive_stg1,write-cache=on,bus=scsi1.0 \
    \
    -device pcie-root-port,id=pcie_port_2,slot=6,chassis=6,addr=0x6,bus=pcie.0,hotplug=off \
    -device virtio-scsi-pci,id=scsi2,bus=pcie_port_2,addr=0x0,hotplug=on \
    -device scsi-hd,id=stg2,drive=drive_stg2,write-cache=on,bus=scsi2.0 \
    \
    -device pcie-root-port,id=pcie_port_3,slot=7,chassis=7,addr=0x7,bus=pcie.0,hotplug=on \
    -device virtio-scsi-pci,id=scsi3,bus=pcie_port_3,addr=0x0,hotplug=off \
    -device scsi-hd,id=stg3,drive=drive_stg3,write-cache=on,bus=scsi3.0 \
    \
    -device pcie-root-port,id=pcie_port_4,slot=8,chassis=8,addr=0x8,bus=pcie.0,hotplug=on \
    -device virtio-scsi-pci,id=scsi4,bus=pcie_port_4,addr=0x0,hotplug=on \
    -device scsi-hd,id=stg4,drive=drive_stg4,write-cache=on,bus=scsi4.0 \
    \
    -device pcie-root-port,id=pcie_port_5,slot=9,chassis=9,addr=0x9,bus=pcie.0,hotplug=off \
    \
    -device pcie-root-port,id=pcie_port_6,slot=10,chassis=10,addr=0x10,bus=pcie.0,hotplug=off \
    \
    -device pcie-root-port,id=pcie_port_7,slot=11,chassis=11,addr=0x11,bus=pcie.0 \
    \
    -device pcie-root-port,id=pcie_port_8,slot=12,chassis=12,addr=0x12,bus=pcie.0 \




steps(){
echo
 qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
#host
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G

#qmp
{"execute":"qmp_capabilities"}

{"execute": "device_add", "arguments": {"driver": "virtio-scsi-pci", "id": "scsi5",  "bus": "pcie_port_5","addr":0,"hotplug":"off"}, "id": "t07OBwF5"}
{"execute": "device_add", "arguments": {"driver": "virtio-scsi-pci", "id": "scsi6",  "bus": "pcie_port_6","addr":0,"hotplug":"on"}, "id": "t07OBwF6"}
{"execute": "device_add", "arguments": {"driver": "virtio-scsi-pci", "id": "scsi7",  "bus": "pcie_port_7","addr":0,"hotplug":"off"}, "id": "t07OBwF7"}
{"execute": "device_add", "arguments": {"driver": "virtio-scsi-pci", "id": "scsi8",  "bus": "pcie_port_8","addr":0,"hotplug":"on"}, "id": "t07OBwF8"}

{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg5", "drive": "drive_stg5", "bus": "scsi5.0"}, "id": "t07OBwF5"}
{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg6", "drive": "drive_stg6", "bus": "scsi6.0"}, "id": "t07OBwF6"}
{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg7", "drive": "drive_stg7", "bus": "scsi7.0"}, "id": "t07OBwF7"}
{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg8", "drive": "drive_stg8", "bus": "scsi8.0"}, "id": "t07OBwF8"}

{"execute":"query-block"}
{"execute":"query-pci"}
######################################################3
{"execute":"qmp_capabilities"}

{"execute": "device_del", "arguments": {"id": "stg1"}, "id": "XVosfhH1"}
{"execute": "device_del", "arguments": {"id": "stg2"}, "id": "XVosfhH2"}

{"execute": "device_del", "arguments": {"id": "stg3"}, "id": "XVosfhH3"}
{"execute": "device_del", "arguments": {"id": "stg4"}, "id": "XVosfhH4"}

{"execute": "device_del", "arguments": {"id": "stg5"}, "id": "XVosfhH5"}
{"execute": "device_del", "arguments": {"id": "stg6"}, "id": "XVosfhH6"}

{"execute": "device_del", "arguments": {"id": "stg7"}, "id": "XVosfhH7"}
{"execute": "device_del", "arguments": {"id": "stg8"}, "id": "XVosfhH8"}

###################

{"execute": "device_del", "arguments": {"id": "scsi1"}, "id": "XVosfhH1"}
{"execute": "device_del", "arguments": {"id": "scsi2"}, "id": "XVosfhH2"}

{"execute": "device_del", "arguments": {"id": "scsi3"}, "id": "XVosfhH3"}
{"execute": "device_del", "arguments": {"id": "scsi4"}, "id": "XVosfhH4"}

{"execute": "device_del", "arguments": {"id": "scsi5"}, "id": "XVosfhH5"}
{"execute": "device_del", "arguments": {"id": "scsi6"}, "id": "XVosfhH6"}

{"execute": "device_del", "arguments": {"id": "scsi7"}, "id": "XVosfhH7"}
{"execute": "device_del", "arguments": {"id": "scsi8"}, "id": "XVosfhH8"}

##############################3
{"execute": "device_del", "arguments": {"id": "pcie_port_1"}, "id": "XVosfhH1"}
{"execute": "device_del", "arguments": {"id": "pcie_port_2"}, "id": "XVosfhH2"}

{"execute": "device_del", "arguments": {"id": "pcie_port_3"}, "id": "XVosfhH3"}
{"execute": "device_del", "arguments": {"id": "pcie_port_4"}, "id": "XVosfhH4"}

{"execute": "device_del", "arguments": {"id": "pcie_port_5"}, "id": "XVosfhH5"}
{"execute": "device_del", "arguments": {"id": "pcie_port_6"}, "id": "XVosfhH6"}

{"execute": "device_del", "arguments": {"id": "pcie_port_7"}, "id": "XVosfhH7"}
{"execute": "device_del", "arguments": {"id": "pcie_port_8"}, "id": "XVosfhH8"}

}
