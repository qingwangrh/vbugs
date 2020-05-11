#q35 and pc have same issue

q35(){

 /usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x2 \
  -m 8096 \
  -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2 \
  -device pvpanic,ioport=0x505,id=idWW4fRE \
  -device qemu-xhci,id=usb1,bus=pcie.0,addr=0x3 \
  \
  -device pcie-root-port,id=pcie_port_7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
  -device pcie-root-port,id=pcie_port_8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0,addr=0x4,iothread=iothread0 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on,serial=osdisk000\
  \
  -blockdev node-name=data_image1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/stg1.qcow2,aio=threads \
  -blockdev node-name=data1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=data_image1 \
  -device scsi-hd,id=disk1,drive=data1,write-cache=on,bus=scsi0.0  \
  \
  \
  -blockdev node-name=data_image2,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/stg2.qcow2,aio=threads \
  -blockdev node-name=data2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=data_image2 \
  -device virtio-blk-pci,id=disk2,drive=data2,write-cache=on,bus=pcie_port_7  \
  \
  -device virtio-net-pci,mac=9a:7f:65:c9:ec:b8,id=idCBhCiy,netdev=id1uqNcV,bus=pcie.0,addr=0x5 \
  -netdev tap,id=id1uqNcV,vhost=on \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0,addr=0x6 \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=scsi1.0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :6 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm -monitor stdio \
  -qmp tcp:0:5956,server,nowait \


}

#pc(){
#
#/usr/libexec/qemu-kvm \
#  -name 'avocado-vt-vm1' \
#  -sandbox on \
#  -machine pc \
#  -nodefaults \
#  -device VGA,bus=pci.0,addr=0x2 \
#  -m 8096 \
#  -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2 \
#  -device pvpanic,ioport=0x505,id=idWW4fRE \
#  -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
#  \
#  -object iothread,id=iothread0 \
#  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
#  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-7,addr=0x0,thread=iothread0 \
#  -blockdev node-name=file_image1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2,aio=threads \
#  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
#  -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=scsi0.0,serial=osdisk000 \
#  \
#  -blockdev node-name=data_image1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/stg0.qcow2,aio=threads \
#  -blockdev node-name=data1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=data_image1 \
#  -device scsi-hd,id=disk1,drive=data1,bootindex=0,write-cache=on,bus=scsi0.0 \
#  \
#  -device virtio-net-pci,mac=9a:7f:65:c9:ec:b8,id=idCBhCiy,netdev=id1uqNcV,bus=pci.0,addr=0x5 \
#  -netdev tap,id=id1uqNcV,vhost=on \
#  -device virtio-scsi-pci,id=scsi1,bus=pci.0,addr=0x6 \
#  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
#  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
#  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=scsi1.0 \
#  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
#  -vnc :6 \
#  -rtc base=localtime,clock=host,driftfix=slew \
#  -boot menu=off,order=cdn,once=c,strict=off \
#  -enable-kvm -monitor stdio \
#  -qmp tcp:0:5956,server,nowait
#
#}

#pc
q35

steps() {
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
#q35

{'execute':'qmp_capabilities'}

{"execute":"blockdev-add","arguments":{"node-name":"data3","driver":"qcow2","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/stg3.qcow2"}}}
{"execute":"blockdev-add","arguments":{"node-name":"data4","driver":"qcow2","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/stg4.qcow2"}}}

{'execute':'device_add','arguments':{'driver':'scsi-hd','drive':'data3','bus':'scsi0.0','id':'data3',"serial":"data3"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk4", "drive": "data4", "write-cache": "on", "bus": "pcie_port_8","serial":"data4"}}

#no serial will hit hang bug when execute quit command

{'execute':'device_add','arguments':{'driver':'scsi-hd','drive':'data3','bus':'scsi0.0','id':'data3'}}

{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk4", "drive": "data4", "bus": "pcie_port_8"}}


{"execute":"device_del","arguments":{"id":"disk3"}}
{"execute":"device_del","arguments":{"id":"disk4"}}

#pc
  {'execute': 'qmp_capabilities'}
  {"execute": "blockdev-add", "arguments": {"node-name": "data_stg3", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg3.qcow2", "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "data3", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "data_stg3"}}
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "disk3", "drive": "data3", "write-cache": "on", "bus": "pci.0", "addr": "0x8"}}

  #wait 10s in guest then guest crash
  #no issue on drive and blk mode
  #ok
  -drive id=drive_image1,if=none,format=raw,file=/home/kvm_autotest_root/images/win2019-3-64-virtio-scsi.qcow2 \
  -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on

  #ok
  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,addr=0x7,bus=pci.0 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-3-64-virtio-scsi.raw,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=raw,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie.0-root-port-7


It works well when hotplug a separate virtio-scsi-pci controller

{"execute":"blockdev-add","arguments":{"node-name":"file_image3","driver":"qcow2","file":{"driver":"file","filename":"/home/disk/data.qcow2"}}}

{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"virtio_scsi_pci1","bus":"pcie.0-root-port-9","addr":"0x0"}}

{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"file_image3","id":"data_disk","bus":"virtio_scsi_pci1.0"}}

{"execute":"device_del","arguments":{"id":"data_disk"} }


}
