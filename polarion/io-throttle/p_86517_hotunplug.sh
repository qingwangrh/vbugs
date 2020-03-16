
/usr/libexec/qemu-kvm \
    -name 'throttle-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -object iothread,id=iothread0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-3,addr=0x0,iothread=iothread0 \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-4,addr=0x0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=os_img \
    -blockdev driver=qcow2,node-name=os_drive,file=os_img \
    -device scsi-hd,drive=os_drive,bus=scsi0.0,id=os_disk \
    \
    -object throttle-group,id=foo,x-iops-read=100,x-bps-read=512000,x-iops-write=50,x-bps-write=1024000 \
    -object throttle-group,id=foo2,x-iops-total=80,x-bps-total=409600 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.raw \
    -blockdev driver=raw,node-name=drive_stg1,file=file_stg1 \
    -blockdev driver=throttle,throttle-group=foo,node-name=foo1,file=drive_stg1 \
    -device virtio-blk-pci,drive=foo1,id=data,bus=pcie.0-root-port-6,addr=0x0,iothread=iothread0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg2,filename=/home/kvm_autotest_root/images/stg2.raw \
    -blockdev driver=raw,node-name=drive_stg2,file=file_stg2 \
    -blockdev driver=throttle,throttle-group=foo,node-name=foo2,file=drive_stg2 \
    -device virtio-blk-pci,drive=foo2,id=data2,bus=pcie.0-root-port-7,addr=0x0,iothread=iothread0 \
    \
    -object throttle-group,id=foo3,x-iops-total=100,x-iops-size=8192 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 8G  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \



steps() {

echo

    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso  \
 -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0  \
 -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso  \
 -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0  \
 -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso  \
 -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.2,unit=0  \

    -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.raw  \
 -blockdev driver=raw,node-name=drive_stg1,file=file_stg1  \
 -blockdev driver=throttle,throttle-group=foo,node-name=foo1,file=file_stg1  \
 -device scsi-hd,drive=foo1,id=data,bus=scsi2.0,id=os_disk  \
 #bug scsi-hd with data plane enabled
    -device scsi-hd,drive=foo1,id=data,bus=scsi2.0,id=os_disk  \
 #ok
    -device virtio-blk-pci,drive=foo1,id=data,bus=pcie.0-root-port-6,addr=0x0,iothread=iothread0

    {"execute": "qmp_capabilities"}
    {"execute": "query-block"}
    {"execute":"qom-get","arguments":{"path":"foo","property":"limits"}}

    {"execute": "blockdev-add","arguments":{"driver":"throttle","throttle-group":"foo","node-name":"new_disk","file":{"driver":"raw","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/stg2.raw"}}}}
    {"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"new_disk","id":"scsi0-0-2-0"}}

    {"execute": "blockdev-add","arguments":{"driver":"throttle","throttle-group":"foo2","node-name":"new_disk2","file":{"driver":"raw","file":{"driver":"file","filename":"/home/kvm_autotest_root/images/stg3.raw"}}}}
    {"execute":"device_add","arguments":{"driver":"virtio-blk-pci","drive":"new_disk2","id":"data2","bus":"pcie.0-root-port-7"}}


    {"execute":"device_del","arguments":{"id":"scsi0-0-2-0"}}
    {"execute": "blockdev-del","arguments": { "node-name": "new_disk"}}

    {"execute":"device_del","arguments":{"id":"data2"}}
    {"execute": "blockdev-del","arguments": { "node-name": "new_disk2"}}

    fio --filename=/dev/vda --direct=1 --rw=randrw --bs=4k --size=100M --name=test --iodepth=1 --runtime=30

    fio --filename=/dev/vda --direct=1 --rw=read --bs=4k --size=100M --name=test --iodepth=1 --runtime=10
    fio --filename=/dev/vdb --direct=1 --rw=randrw --bs=4k --size=100M --name=test --iodepth=1 --runtime=10

}