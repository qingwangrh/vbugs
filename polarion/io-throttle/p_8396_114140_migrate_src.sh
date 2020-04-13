
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
    -object throttle-group,id=foo,x-bps-total=1024000,x-iops-total=100 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-3,addr=0x0 \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-4,addr=0x0,iothread=iothread0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/mnt/gluster/wq/rhel820-64-virtio.qcow2,node-name=os_img \
    -blockdev driver=qcow2,node-name=os_drive,file=os_img \
    -device scsi-hd,drive=os_drive,bus=scsi0.0,id=os_disk \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=//mnt/gluster/wq/stg1.raw \
    -blockdev driver=raw,node-name=drive_stg1,file=file_stg1 \
    -blockdev driver=throttle,throttle-group=foo,node-name=foo1,file=drive_stg1 \
    -device virtio-blk-pci,drive=foo1,id=data,bus=pcie.0-root-port-6,addr=0x0,iothread=iothread0 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 8G  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \



steps() {
    #ABI different host
    mount.glusterfs gluster-virt-qe-01.lab.eng.pek2.redhat.com:/gv0 /mnt/gluster

    {"execute": "qmp_capabilities"}
    {"execute": "migrate","arguments":{"uri": "tcp:10.73.196.25:5200"}}

    {"execute": "migrate","arguments":{"uri": "tcp:10.73.114.14:5200"}}

    {"execute": "migrate","arguments":{"uri": "tcp:DSTHostIP:5200"}}


    fio --filename=/dev/vda --direct=1 --rw=randrw --bs=4k --size=100M --name=test --iodepth=1 --runtime=30

    fio --filename=/dev/vda --direct=1 --rw=read --bs=4k --size=100M --name=test --iodepth=1 --runtime=10

}