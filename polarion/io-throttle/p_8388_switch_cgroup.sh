
lodev=/dev/loop4
lvremove -fy /dev/vg/lv
vgremove vg
pvremove ${lodev}
losetup -d ${lodev}
umount -l /mnt/cgroup
rm -rf /mnt/cgroup;mkdir -p /mnt/cgroup
mount -t cgroup -o blkio blkio /mnt/cgroup


mkdir -p /mnt/cgroup/blkio1
mkdir -p /mnt/cgroup/blkio2

qemu-img create -f raw /tmp/cgroup.raw 10G
losetup -f
losetup ${lodev} /tmp/cgroup.raw
pvcreate ${lodev}
vgcreate vg ${lodev} -f
lvcreate -L 5G -n lv vg

 ls -l /dev/vg/lv
id=`ls -l /dev/vg/lv|cut -d "-" -f 3`
ls -l /dev/dm-$id

fn=`ls -l /dev/dm-$id|cut -d "," -f 1|rev|cut -f 1 -d " "|rev`
sn=`ls -l /dev/dm-$id|cut -d "," -f 2|awk '$1=$1'|cut -f 1 -d " "`
echo "$fn:$sn"
cd /mnt/cgroup/blkio1
echo $fn:$sn 512000 > blkio.throttle.read_bps_device
echo $fn:$sn 512000 > blkio.throttle.write_bps_device
cat blkio.throttle.read_bps_device
cat blkio.throttle.write_bps_device
cd /mnt/cgroup/blkio2
echo $fn:$sn 1048576 > blkio.throttle.read_bps_device
echo $fn:$sn 1048576 > blkio.throttle.write_bps_device
cat blkio.throttle.read_bps_device
cat blkio.throttle.write_bps_device
#exit

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
    -object throttle-group,id=foo,x-bps-total=1024000,x-iops-total=100 \
    -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,node-name=file_stg1,filename=/dev/vg/lv \
    -blockdev driver=raw,node-name=drive_stg1,file=file_stg1 \
    -drive file=/dev/vg/lv,if=none,id=drive_stg2,format=raw,cache=none \
    -device scsi-hd,drive=drive_stg1,id=data \
    \
    -object throttle-group,id=foo2,x-iops-total=100,x-iops-size=8192 \
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
#host
    pid=`pidof qemu-kvm`;echo ${pid}
    echo ${pid} >  /mnt/cgroup/blkio2/tasks
    cat /mnt/cgroup/blkio2/tasks

    echo ${pid} >  /mnt/cgroup/blkio1/tasks
    cat /mnt/cgroup/blkio1/tasks
    #guset
    dd if=/dev/zero of=/dev/sdb bs=64K count=10 oflag=direct

    {"execute": "qmp_capabilities"}
    {"execute": "query-block"}
    {"execute":"qom-get","arguments":{"path":"foo","property":"limits"}}
    {"execute":"qom-set","arguments":{"path":"foo", "property":"limits", "value":{"iops-total": 120}}}
    {"execute":"qom-set","arguments":{"path":"foo", "property":"limits", "value":{"iops-total": "#"}}}
    {"execute":"qom-set","arguments":{"path":"foo", "property":"limits", "value":{"iops-total": -2}}}
    {"execute":"qom-set","arguments":{"path":"foo", "property":"limits", "value":{"iops-total": 0.2}}}

    fio --filename=/dev/vda --direct=1 --rw=randrw --bs=4k --size=100M --name=test --iodepth=1 --runtime=30

    fio --filename=/dev/vda --direct=1 --rw=read --bs=4k --size=100M --name=test --iodepth=1 --runtime=10
    fio --filename=/dev/vdb --direct=1 --rw=randrw --bs=4k --size=100M --name=test --iodepth=1 --runtime=10

}