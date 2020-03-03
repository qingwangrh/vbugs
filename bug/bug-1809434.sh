umount -l /tmp/xtmpfs;rm -rf /tmp/xtmpfs;mkdir -p /tmp/xtmpfs;

mount -t tmpfs -o rw,nosuid,nodev,seclabel tmpfs /tmp/xtmpfs

/usr/bin/qemu-img create -f raw /tmp/xtmpfs/stg0.raw 50M

losetup -d /dev/loop6

losetup /dev/loop6 /tmp/xtmpfs/stg0.raw && chmod 666 /dev/loop6

/usr/bin/qemu-img create -f qcow2 /dev/loop6 500M

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 2G  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -cpu 'Opteron_G5',+kvm_pv_unhalt  \
    \
    -device pvpanic,ioport=0x505,id=idJenAbB \
    \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -object iothread,id=iothread2 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4,iothread=iothread0 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -blockdev node-name=file_stg1,driver=host_device,aio=native,filename=/dev/loop6,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg1 \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,write-cache=on,rerror=stop,werror=stop,serial=TARGET_DISK0,bus=pci.0,addr=0x5,iothread=iothread1 \
    -device virtio-net-pci,mac=9a:bb:e1:81:7e:f5,id=id1XDlV6,netdev=idgQKvAZ,bus=pci.0,addr=0x6  \
    -netdev tap,id=idgQKvAZ,vhost=on \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \


steps(){
#guest
    dd if=/dev/urandom of=/dev/vda oflag=direct bs=500M
#host
qemu-img resize -f raw /tmp/xtmpfs/stg0.raw 150M && losetup -c /dev/loop6

}