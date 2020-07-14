/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 14336  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel820-64-virtio.qcow2 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:21:f7:4a:1e:bc,id=idRuZxfv,netdev=idOpPVAe,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idOpPVAe,vhost=on  \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,bus=ide.0,unit=0  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
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


steps(){

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg5.qcow2 5G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg6.qcow2 6G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 7G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg8.qcow2 8G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg9.qcow2 9G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg10.qcow2 10G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg11.qcow2 11G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg12.qcow2 12G


#qmp

{"execute":"qmp_capabilities"}

{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"virtio_scsi_pci1","bus":"pcie_extra_root_port_1","addr":"0x0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk1","driver":"file","filename":"/home/kvm_autotest_root/images/stg1.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk1","driver":"qcow2","file":"data_disk1"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk2","driver":"file","filename":"/home/kvm_autotest_root/images/stg2.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk2","driver":"qcow2","file":"data_disk2"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk3","driver":"file","filename":"/home/kvm_autotest_root/images/stg3.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk3","driver":"qcow2","file":"data_disk3"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk4","driver":"file","filename":"/home/kvm_autotest_root/images/stg4.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk4","driver":"qcow2","file":"data_disk4"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk5","driver":"file","filename":"/home/kvm_autotest_root/images/stg5.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk5","driver":"qcow2","file":"data_disk5"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk6","driver":"file","filename":"/home/kvm_autotest_root/images/stg6.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk6","driver":"qcow2","file":"data_disk6"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk7","driver":"file","filename":"/home/kvm_autotest_root/images/stg7.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk7","driver":"qcow2","file":"data_disk7"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk8","driver":"file","filename":"/home/kvm_autotest_root/images/stg8.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk8","driver":"qcow2","file":"data_disk8"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk9","driver":"file","filename":"/home/kvm_autotest_root/images/stg9.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk9","driver":"qcow2","file":"data_disk9"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk10","driver":"file","filename":"/home/kvm_autotest_root/images/stg10.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk10","driver":"qcow2","file":"data_disk10"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk11","driver":"file","filename":"/home/kvm_autotest_root/images/stg11.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk11","driver":"qcow2","file":"data_disk11"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk12","driver":"file","filename":"/home/kvm_autotest_root/images/stg12.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk12","driver":"qcow2","file":"data_disk12"}}

{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk1","id":"data_disk1","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk2","id":"data_disk2","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk3","id":"data_disk3","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk4","id":"data_disk4","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk5","id":"data_disk5","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk6","id":"data_disk6","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk7","id":"data_disk7","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk8","id":"data_disk8","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk9","id":"data_disk9","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk10","id":"data_disk10","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk11","id":"data_disk11","bus":"virtio_scsi_pci1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk12","id":"data_disk12","bus":"virtio_scsi_pci1.0"}}


{'execute':'device_del','arguments':{'id':'data_disk1'}}
{'execute':'device_del','arguments':{'id':'data_disk2'}}
{'execute':'device_del','arguments':{'id':'data_disk3'}}
{'execute':'device_del','arguments':{'id':'data_disk4'}}
{'execute':'device_del','arguments':{'id':'data_disk5'}}
{'execute':'device_del','arguments':{'id':'data_disk6'}}
{'execute':'device_del','arguments':{'id':'data_disk7'}}
{'execute':'device_del','arguments':{'id':'data_disk8'}}
{'execute':'device_del','arguments':{'id':'data_disk9'}}
{'execute':'device_del','arguments':{'id':'data_disk10'}}
{'execute':'device_del','arguments':{'id':'data_disk11'}}
{'execute':'device_del','arguments':{'id':'data_disk12'}}


{'execute':'device_del','arguments':{'id':'virtio_scsi_pci1'}}
#BUG:if we do not delete  virtio_scsi_pci1, only 8 disk can be deleted .

}