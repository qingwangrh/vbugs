/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox off  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2  \
    \
    -device nec-usb-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/iscsi_mount/rhel820-64-virtio-scsi.qcow2,node-name=my_file \
    -blockdev driver=qcow2,node-name=my,file=my_file \
    -device scsi-hd,drive=my,bus=virtio_scsi_pci0.0 \
    -device virtio-net-pci,mac=9a:ad:ae:af:b0:b1,id=id942Wof,vectors=4,netdev=idirzdj4,bus=pci.0,addr=0x5  \
    -netdev tap,id=idirzdj4,vhost=on \
    -m 4G  \
    -smp 4,maxcpus=4,cores=2,threads=1,sockets=2  \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,strict=off,order=cdn,once=d  \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -device virtio-scsi-pci,id=scsi1,bus=pci.0,addr=0x6 \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/iscsi_mount/data.qcow2,node-name=drive2 \
    -blockdev driver=qcow2,node-name=my1,file=drive2 \
    -device scsi-hd,drive=my1,id=data-disk1,bus=scsi1.0 \


steps(){
git clone https://github.com/stressapptest/stressapptest.git
cd stressapptest && ./configure && make && make install

    stressapptest -M 100 -s 1000


(qemu)
migrate -d tcp:10.73.114.14:5800
migrate_set_downtime 20


migrate -d tcp:10.73.130.203:5800
migrate_set_downtime 20

}