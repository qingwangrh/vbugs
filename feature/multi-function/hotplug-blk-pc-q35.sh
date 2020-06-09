#!/usr/bin/env bash
/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 7168  \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Client',+kvm_pv_unhalt \
    -device pvpanic,ioport=0x505,id=ida93kN5 \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,multifunction=on,bus=pci.0,addr=0x4 \
    \
    -blockdev node-name=file_stg0,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg0.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg0,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg0 \
    -device virtio-blk-pci,id=disk0,drive=drive_stg0,bootindex=1,write-cache=on,multifunction=on,bus=pci.0,addr=0x4.2 \
    \
    -device virtio-net-pci,mac=9a:6c:1d:bb:74:aa,id=idk21dGl,netdev=idKrZncQ,bus=pci.0,addr=0x5  \
    -netdev tap,id=idKrZncQ,vhost=on  \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -qmp tcp:0:5955,server,nowait \




q35(){

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 7168  \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Client',+kvm_pv_unhalt \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,multifunction=on,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:f4:f0:0e:dc:05,id=id4dZ4px,netdev=idnbbqEr,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idnbbqEr,vhost=on,vhostfd=21,fd=14  \
    -vnc :0  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5

}


steps(){

#host
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G

#qmp
{"execute":"qmp_capabilities"}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk1","driver":"file","filename":"/home/kvm_autotest_root/images/stg1.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "data1","driver":"qcow2","file":"data_disk1"}}

{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk1", "drive": "data1", "multifunction":"on","bus": "pci.0", "addr": "0x4.1"}}

#
{"error": {"class": "GenericError", "desc": "PCI: slot 4 function 0 already ocuppied by virtio-blk-pci, new func virtio-blk-pci cannot be exposed to guest."}}

#same result as above
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk1", "drive": "data1", "bus": "pci.0", "addr": "0x4.1"}}

#q35
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk1", "drive": "data1", "multifunction":"on","bus": "pcie-root-port-2", "addr": "0x0.1"}}

#new func
{"execute":"qmp_capabilities"}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk2","driver":"file","filename":"/home/kvm_autotest_root/images/stg2.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "data2","driver":"qcow2","file":"data_disk2"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk3","driver":"file","filename":"/home/kvm_autotest_root/images/stg3.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "data3","driver":"qcow2","file":"data_disk3"}}
{"execute": "blockdev-add","arguments": {"node-name":"data_disk4","driver":"file","filename":"/home/kvm_autotest_root/images/stg4.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "data4","driver":"qcow2","file":"data_disk4"}}

    {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk2", "drive": "data2", "multifunction":"on","bus": "pci.0", "addr": "0x6.1"}}
    {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk3", "drive": "data3", "multifunction":"on","bus": "pci.0", "addr": "0x6.3"}}

#the order is important. if hotplug this disk first .then above 2 disk2 failed on PCI: slot X function 0 already ocuppied by virtio-blk-pci, new func virtio-blk-pci cannot be exposed to guest.
 {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk4", "drive": "data4", "multifunction":"on","bus": "pci.0", "addr": "0x6"}}



}