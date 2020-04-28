qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data3.qcow2 3G

blk(){

 /usr/libexec/qemu-kvm \
        -name 'guest-rhel77' \
        -machine q35 \
        -nodefaults \
        -vga qxl \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
        -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel820-64-virtio.qcow2 \
        -device virtio-blk-pci,id=virtio_blk_pci0,drive=drive_image1,bus=pcie.0-root-port-5,addr=0x0,bootindex=0 \
        -drive id=drive_image2,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/data1.qcow2 \
        -device virtio-blk-pci,id=virtio_blk_pci1,drive=drive_image2,bus=pcie.0-root-port-6,addr=0x0,bootindex=1 \
        -vnc :5 \
        -monitor stdio \
        -m 8192 \
        -smp 8 \
        -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
        -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b3,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
        -netdev tap,id=idxgXAlm \
        -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpmonitor1-20180220-094308-h9I6hRsI,server,nowait \
        -mon chardev=qmp_id_qmpmonitor1,mode=control  \
       -qmp tcp:0:5955,server,nowait \

}

scsi(){
/usr/libexec/qemu-kvm \
        -name 'guest-rhel77' \
        -machine q35 \
        -nodefaults \
        -vga qxl \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
        -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi1,bus=pcie.0 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2 \
        -device scsi-hd,id=virtio_blk_pci0,drive=drive_image1,bus=scsi1.0,bootindex=0 \
        -drive id=drive_image2,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/data1.qcow2 \
        -device scsi-hd,id=virtio_blk_pci1,drive=drive_image2,bus=scsi1.0,bootindex=1 \
        -vnc :5 \
        -monitor stdio \
        -m 8192 \
        -smp 8 \
        -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
        -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b3,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
        -netdev tap,id=idxgXAlm \
        -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpmonitor1-20180220-094308-h9I6hRsI,server,nowait \
        -mon chardev=qmp_id_qmpmonitor1,mode=control  \
       -qmp tcp:0:5955,server,nowait \



}

blk
#scsi

steps(){
 #host
 qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data3.qcow2 3G

{"execute":"qmp_capabilities"}

{"execute": "device_del", "arguments": {"id": "virtio_blk_pci1"} , "id": "XVosfh01"}


#blk
 {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_image3,if=none,snapshot=off,aio=native,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/data3.qcow2"}}

    {"execute":"device_add","arguments":{"driver":"virtio-blk-pci","drive":"drive_image3","id":"virtio_blk_pci1","bus":"pcie.0-root-port-6"}}


#scsi
{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_image3,if=none,snapshot=off,aio=native,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/data3.qcow2"}}

     {"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"drive_image3","id":"virtio_blk_pci1","bus":"scsi1.0"}}


 #guest
dev=/dev/vdb
 mkfs.ext4 /dev/vdb
 yes|pvcreate /dev/vdb
 vgcreate vg /dev/vdb -f
 lvcreate -L 1G -n lv vg

lvremove -fy /dev/vg/lv
vgremove vg
pvremove /dev/vdb

dev=/dev/vdb
 mkfs.ext4 /dev/sdb
 yes|pvcreate /dev/sdb
 vgcreate vg /dev/sdb -f
 lvcreate -L 1G -n lv vg

mkfs.ext4 /dev/vdb;mkdir -p /home/test;mount /dev/vdb /home/test

 }