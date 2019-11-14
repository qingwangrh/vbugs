# mount -o mand qing:/home/exports x
# qemu-img create -f raw base.img 20G
# chmod g+s,g-x base.img
#install

 /usr/libexec/qemu-kvm \
        -name 'guest-rhel77' \
        -machine q35 \
        -nodefaults \
        -vga qxl \
        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso \
        -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/root/x/images/base.img \
        -device virtio-blk-pci,id=virtio_blk_pci0,drive=drive_image1,bus=pcie.0-root-port-5,addr=0x0,bootindex=0 \
        -vnc :0 \
        -monitor stdio \
        -m 8192 \
        -smp 8 \
        -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
        -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b3,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
        -netdev tap,id=idxgXAlm \
        -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpmonitor1-20180220-094308-h9I6hRsI,server,nowait \
        -mon chardev=qmp_id_qmpmonitor1,mode=control  \