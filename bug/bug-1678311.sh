#!/usr/bin/env bash
#Bug 1678311 - No "DEVICE_DELETED" event in qmp after "device_del"
#https://bugzilla.redhat.com/show_bug.cgi?id=1678311

pc(){
/usr/libexec/qemu-kvm \
        -name 'avocado-vt-vm1' \
        -machine pc \
        -nodefaults \
        -device VGA,bus=pci.0,addr=0x2 \
        -object iothread,id=iothread0 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
        -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pci.0 \
        -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,iothread=iothread0,bus=pcie.0-root-port-3,addr=0x0 \
        -m 15360 \
        -smp 12,maxcpus=12,cores=6,threads=1,sockets=2 \
       \
        -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pci.0 \
        -device virtio-net-pci,mac=9a:31:32:33:34:35,id=idYxHDLn,vectors=4,netdev=idoOknQC,bus=pcie.0-root-port-4,addr=0x0 \
        -netdev tap,id=idoOknQC,vhost=on \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pci.0 \
        -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-5,addr=0x0 \
        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
        -device scsi-cd,id=cd1,drive=drive_cd1,bootindex=1 \
        -drive id=drive_cd2,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso  \
        -device scsi-cd,id=cd2,drive=drive_cd2,bootindex=2 \
        -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=2,addr=0x7,bus=pci.0 \
        -device qemu-xhci,id=usb1,bus=pcie.0-root-port-7,addr=0x0 \
        -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
        -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pci.0 \
        -vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:5956,server,nowait \
        -monitor stdio \

}

pc_teststep() {
#pc when do device_del , this disk can not removed in guest.
  {'execute': 'qmp_capabilities'}

  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/data0.raw", "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "raw", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}}
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pcie_extra_root_port_0", "addr": "0x0"}}

  {"execute": "device_del", "arguments": {"id": "stg0"}}
  {"execute": "query-status"}

  {"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg0", "drive": "drive_stg0", "write-cache": "on"}}
}

#pc

q35(){

/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x1 \
  -m 13072 \
  -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2 \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
  -object iothread,id=iothread0 \
  -object iothread,id=iothread1 \
  -object iothread,id=iothread2 \
  -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,iothread=iothread0,bus=pcie.0-root-port-3,addr=0x0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:a6:91:a0:8f:22,id=idw2eatJ,netdev=idpFq5nx,bus=pcie.0-root-port-4,addr=0x0 \
  -netdev tap,id=idpFq5nx,vhost=on \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=native,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :6 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -enable-kvm \
  -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
  -device pcie-root-port,id=pcie_extra_root_port_1,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
  -monitor stdio \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5956,server,nowait \
  -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

}

teststep() {
  {'execute': 'qmp_capabilities'}
  {'execute': 'stop'}

  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/data0.raw", "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "raw", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}}
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "iothread": "iothread1", "bus": "pcie_extra_root_port_0", "addr": "0x0"}}
  {'execute': 'cont'}
  dd if=/dev/vdb of=/dev/null bs=1k count=1000 iflag=direct && dd if=/dev/zero of=/dev/vdb bs=1k count=1000 oflag=direct
  #{'execute': 'stop'}
  {"execute": "device_del", "arguments": {"id": "stg0"}}
  {"execute": "query-status"}

  {"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg0", "drive": "drive_stg0", "write-cache": "on"}}
}


case2(){
#hotplug 2 blk disks

  /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1 \
    -m 13072  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie.0-root-port-3,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:a6:91:a0:8f:22,id=idw2eatJ,netdev=idpFq5nx,bus=pcie.0-root-port-4,addr=0x0  \
    -netdev tap,id=idpFq5nx,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=native,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :6  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device pcie-root-port,id=pcie_extra_root_port_1,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5956,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \


{"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/storage0.qcow2", "cache": {"direct": true, "no-flush": false}} }
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"} }
{"execute": "blockdev-add", "arguments": {"node-name": "file_stg1", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/storage1.qcow2", "cache": {"direct": true, "no-flush": false}} }
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg1", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg1"} }


{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on",   "bus": "pcie_extra_root_port_0", "addr": "0x0"}, "id": "wZQGmQC1"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg1", "drive": "drive_stg1", "write-cache": "on",   "bus": "pcie_extra_root_port_1", "addr": "0x0"}, "id": "wZQGmQC2"}

{"execute": "device_del", "arguments": {"id": "stg1"}, "id": "wZQGmQC3"}
{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "wZQGmQC4"}

}

case3(){
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage1.qcow2 2G

  #hotplug 9 scsi disks
  /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 8096  \
    -smp 24,maxcpus=24,cores=12,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_relaxed,hv_spinlocks=0xfff,hv_vapic,hv_time,hv_frequencies,hv_runtime,hv_tlbflush,hv_reenlightenment,hv_stimer_direct,hv_ipi,+kvm_pv_unhalt \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-ehci,id=ehci,bus=pci.0,addr=0x4 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object secret,id=image1_encrypt0,data=redhat \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x5 \
    -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on \
    -device virtio-net-pci,mac=9a:7b:97:4e:5a:92,id=idEF28Hb,netdev=idlRoM9I,bus=pci.0,addr=0x6  \
    -netdev tap,id=idlRoM9I,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=native,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=ide.0,unit=0  \
    -vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:5956,server,nowait \
        -monitor stdio \


}

case3_step(){


{'execute': 'qmp_capabilities'}
{"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/storage0.qcow2", "cache": {"direct": true, "no-flush": false}} }
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"} }
{"execute": "blockdev-add", "arguments": {"node-name": "file_stg1", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/storage1.qcow2", "cache": {"direct": true, "no-flush": false}} }
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg1", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg1"} }

{"execute": "device_add", "arguments": {"id": "virtio_scsi_pci5", "driver": "virtio-scsi-pci", "bus": "pci.0"}}

{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg0", "bus": "virtio_scsi_pci5.0", "drive": "drive_stg0", "write-cache": "on"}, "id": "L4QsYlkN0"}
{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg1", "bus": "virtio_scsi_pci5.0", "drive": "drive_stg1", "write-cache": "on"}, "id": "L4QsYlkN1"}

{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "h78JsAx0"}
{"execute": "device_del", "arguments": {"id": "stg1"}, "id": "h78JsAx1"}

#It have no event on device_del virtio_scsi_pci if no delay with above device_del disk.
{"execute": "device_del", "arguments": {"id": "virtio_scsi_pci5"}, "id": "h78JsAx5"}

}

case3