/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -object iothread,id=iothread0 \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-9,chassis=9,bus=pcie.0,addr=0x9,multifunction=on \
    -device pcie-root-port,id=pcie.0-root-port-9-1,chassis=91,bus=pcie.0,addr=0x9.0x1 \
    -device pcie-root-port,id=pcie.0-root-port-9-2,chassis=92,bus=pcie.0,addr=0x9.0x2 \
    -device pcie-root-port,id=pcie.0-root-port-9-3,chassis=93,bus=pcie.0,addr=0x9.0x3 \
    -device pcie-root-port,id=pcie.0-root-port-9-4,chassis=94,bus=pcie.0,addr=0x9.0x4 \
    -device pcie-root-port,id=pcie.0-root-port-9-5,chassis=95,bus=pcie.0,addr=0x9.0x5 \
    -device pcie-root-port,id=pcie.0-root-port-9-6,chassis=96,bus=pcie.0,addr=0x9.0x6 \
    -device pcie-root-port,id=pcie.0-root-port-9-7,chassis=97,bus=pcie.0,addr=0x9.0x7 \
\
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0,iothread=iothread0,multifunction=on \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-6,addr=0x0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \
    -blockdev driver=qcow2,node-name=disk_2,file=host_disk2 \
    -device scsi-hd,drive=disk_2,bus=scsi0.0,id=host_disk_2 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 13312  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

steps(){
#win cd
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
    -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso \
    -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0 \
    -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.2,unit=0\
#os
-blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2,node-name=host_disk2 \
-blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \

for i in `seq 0 10`;do qemu-img create -f qcow2 "/home/nfs_test/stg$i.qcow2" 1G;done

{"execute": "qmp_capabilities"}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk1","driver":"file","filename":"/home/nfs_test/stg1.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk1","driver":"qcow2","file":"data_disk1"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test1","bus":"pcie.0-root-port-9-1"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk1","id":"data_disk1","bus":"test1.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk2","driver":"file","filename":"/home/nfs_test/stg2.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk2","driver":"qcow2","file":"data_disk2"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test2","bus":"pcie.0-root-port-9-2"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk2","id":"data_disk2","bus":"test2.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk3","driver":"file","filename":"/home/nfs_test/stg3.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk3","driver":"qcow2","file":"data_disk3"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test3","bus":"pcie.0-root-port-9-3"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk3","id":"data_disk3","bus":"test3.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk4","driver":"file","filename":"/home/nfs_test/stg4.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk4","driver":"qcow2","file":"data_disk4"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test4","bus":"pcie.0-root-port-9-4"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk4","id":"data_disk4","bus":"test4.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk5","driver":"file","filename":"/home/nfs_test/stg5.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk5","driver":"qcow2","file":"data_disk5"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test5","bus":"pcie.0-root-port-9-5"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk5","id":"data_disk5","bus":"test5.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk6","driver":"file","filename":"/home/nfs_test/stg6.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk6","driver":"qcow2","file":"data_disk6"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test6","bus":"pcie.0-root-port-9-6"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk6","id":"data_disk6","bus":"test6.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk7","driver":"file","filename":"/home/nfs_test/stg7.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk7","driver":"qcow2","file":"data_disk7"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test7","bus":"pcie.0-root-port-9-7"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk7","id":"data_disk7","bus":"test7.0"}}

{"execute": "blockdev-add","arguments": {"node-name":"data_disk0","driver":"file","filename":"/home/nfs_test/stg0.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk0","driver":"qcow2","file":"data_disk0"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test0","bus":"pcie.0-root-port-9","addr":"0x0","multifunction":"on"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk0","id":"data_disk0","bus":"test0.0"}}

#delete
{"execute":"device_del","arguments":{"id":"data_disk0"} }
{"execute": "blockdev-del","arguments": { "node-name": "disk0"}}
{"execute": "blockdev-del","arguments": { "node-name": "data_disk0"}}
{"execute":"device_del","arguments":{"id":"test0"} }

#multifunction=off
{"execute": "blockdev-add","arguments": {"node-name":"data_disk0","driver":"file","filename":"/home/nfs_test/stg0.qcow2"}}
{"execute": "blockdev-add","arguments": {"node-name": "disk0","driver":"qcow2","file":"data_disk0"}}
{"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"test0","bus":"pcie.0-root-port-9","addr":"0x0","multifunction":"off"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk0","id":"data_disk0","bus":"test0.0"}}

}