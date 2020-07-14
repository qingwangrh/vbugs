#!/usr/bin/env bash

pc(){

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,multifunction=on,bus=pci.0,addr=0x4,iothread=iothread0 \
    -device virtio-net-pci,mac=9a:01:f5:18:bb:c8,id=idLAYRBi,netdev=idEsOS5t,bus=pci.0,addr=0x5  \
    -netdev tap,id=idEsOS5t,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -qmp tcp:0:5955,server,nowait \


}



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
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,multifunction=on,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:f4:f0:0e:dc:05,id=id4dZ4px,netdev=idnbbqEr,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idnbbqEr,vhost=on  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,slot=4,addr=0x4,chassis=4  \

}

q35_static(){

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
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,multifunction=on,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:f4:f0:0e:dc:05,id=id4dZ4px,netdev=idnbbqEr,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idnbbqEr,vhost=on  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,slot=4,addr=0x4,chassis=4  \
    -blockdev node-name=file_stg1,driver=file,filename=/home/kvm_autotest_root/images/stg1.qcow2 \
    -blockdev node-name=drive_stg1,driver=qcow2,file=file_stg1 \
    -blockdev node-name=file_stg2,driver=file,filename=/home/kvm_autotest_root/images/stg2.qcow2 \
    -blockdev node-name=drive_stg2,driver=qcow2,file=file_stg2 \
    -blockdev node-name=file_stg3,driver=file,filename=/home/kvm_autotest_root/images/stg3.qcow2 \
    -blockdev node-name=drive_stg3,driver=qcow2,file=file_stg3 \
    -blockdev node-name=file_stg4,driver=file,filename=/home/kvm_autotest_root/images/stg4.qcow2 \
    -blockdev node-name=drive_stg4,driver=qcow2,file=file_stg4 \
    -blockdev node-name=file_stg5,driver=file,filename=/home/kvm_autotest_root/images/stg5.qcow2 \
    -blockdev node-name=drive_stg5,driver=qcow2,file=file_stg5 \
    -blockdev node-name=file_stg6,driver=file,filename=/home/kvm_autotest_root/images/stg6.qcow2 \
    -blockdev node-name=drive_stg6,driver=qcow2,file=file_stg6 \
    -blockdev node-name=file_stg7,driver=file,filename=/home/kvm_autotest_root/images/stg7.qcow2 \
    -blockdev node-name=drive_stg7,driver=qcow2,file=file_stg7 \
    -blockdev node-name=file_stg8,driver=file,filename=/home/kvm_autotest_root/images/stg8.qcow2 \
    -blockdev node-name=drive_stg8,driver=qcow2,file=file_stg8 \
    \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.1 \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.2 \
    -device virtio-blk-pci,id=stg3,drive=drive_stg3,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.3 \
    -device virtio-blk-pci,id=stg4,drive=drive_stg4,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.4 \
    -device virtio-blk-pci,id=stg5,drive=drive_stg5,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.5 \
    -device virtio-blk-pci,id=stg6,drive=drive_stg6,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.6 \
    -device virtio-blk-pci,id=stg7,drive=drive_stg7,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.7 \
    -device virtio-blk-pci,id=stg8,drive=drive_stg8,multifunction=on,bus=pcie_extra_root_port_0,addr=0x0.0 \



}
#pc
#q35
q35_static

steps(){

#host
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg5.qcow2 5G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg6.qcow2 6G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 7G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg8.qcow2 8G

    #guest
wmic diskdrive get index

    #qmp

{"execute":"qmp_capabilities"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg1", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg1.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg1", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg1"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg2", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg2.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg2", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg2"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg3", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg3.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg3", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg3"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg4", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg4.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg4", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg4"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg5", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg5.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg5", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg5"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg6", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg6.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg6", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg6"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg7", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg7.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg7", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg7"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg8", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg8.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "tvII1jdT"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg8", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg8"}, "id": "dBKzIcv3"}

#pc 1-7 first then 0
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg1", "drive": "drive_stg1", "write-cache": "on", "addr": "0x9.0x1", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg2", "drive": "drive_stg2", "write-cache": "on", "addr": "0x9.0x2", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg3", "drive": "drive_stg3", "write-cache": "on", "addr": "0x9.0x3", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg4", "drive": "drive_stg4", "write-cache": "on", "addr": "0x9.0x4", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg5", "drive": "drive_stg5", "write-cache": "on", "addr": "0x9.0x5", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg6", "drive": "drive_stg6", "write-cache": "on", "addr": "0x9.0x6", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg7", "drive": "drive_stg7", "write-cache": "on", "addr": "0x9.0x7", "bus": "pci.0", "iothread": "iothread1"}, "id": "moK7xdmS"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg8", "drive": "drive_stg8", "write-cache": "on", "multifunction": "on", "addr": "0x9.0x0", "bus": "pci.0", "iothread": "iothread1"}, "id": "95tsCv3C"}

{"execute":"device_del","arguments":{"id":"stg6"}}
#function 7
{"execute":"device_del","arguments":{"id":"stg7"}}

#function 0 will delete all disk
{"execute":"device_del","arguments":{"id":"stg8"}}

{"execute": "blockdev-del","arguments": { "node-name": "drive_stg8"}}
{"execute": "blockdev-del","arguments": { "node-name": "file_stg8"}}

#q35
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg1", "drive": "drive_stg1", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.1"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg2", "drive": "drive_stg2", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.2"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg3", "drive": "drive_stg3", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.3"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg4", "drive": "drive_stg4", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.4"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg5", "drive": "drive_stg5", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.5"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg6", "drive": "drive_stg6", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.6"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg7", "drive": "drive_stg7", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.7"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg8", "drive": "drive_stg8", "multifunction":"on","bus": "pcie_extra_root_port_0","addr":"0x0.0"}}


{"execute":"device_del","arguments":{"id":"stg6"}}
#function 7
{"execute":"device_del","arguments":{"id":"stg7"}}

#function 0 will delete all disk
{"execute":"device_del","arguments":{"id":"stg8"}}

#no cache and aio
{"execute":"qmp_capabilities"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg1", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg1.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg1", "driver": "qcow2",  "file": "file_stg1"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg2", "driver": "file", "filename": "/home/kvm_autotest_root/images/stg2.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg2", "driver": "qcow2",  "file": "file_stg2"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg3", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg3.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg3", "driver": "qcow2",  "file": "file_stg3"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg4", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg4.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg4", "driver": "qcow2",  "file": "file_stg4"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg5", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg5.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg5", "driver": "qcow2",  "file": "file_stg5"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg6", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg6.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg6", "driver": "qcow2",  "file": "file_stg6"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg7", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg7.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "6O9nmhNX"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg7", "driver": "qcow2",  "file": "file_stg7"}, "id": "8JKczL0h"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg8", "driver": "file",  "filename": "/home/kvm_autotest_root/images/stg8.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "tvII1jdT"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg8", "driver": "qcow2",  "file": "file_stg8"}, "id": "dBKzIcv3"}


}