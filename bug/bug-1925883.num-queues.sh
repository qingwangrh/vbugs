/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 2048  \
    -smp 8,maxcpus=8,cores=4,threads=1,dies=1,sockets=2  \
    -cpu 'Cascadelake-Server-noTSX',+kvm_pv_unhalt \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pci.0,addr=0x4,iothread=iothread0 \
    \
    -blockdev node-name=file_stg0,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg0.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg0,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_stg0 \
    -device virtio-blk-pci,id=stg0,drive=drive_stg0,bootindex=1,write-cache=on,num-queues=1,bus=pci.0,addr=0x5,iothread=iothread1 \
    \
    -blockdev node-name=file_stg1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_stg1 \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bootindex=2,write-cache=on,num-queues=8,bus=pci.0,addr=0x6,iothread=iothread0 \
    \
    -blockdev node-name=file_stg2,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_stg2 \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,bootindex=3,write-cache=on,bus=pci.0,addr=0x7,iothread=iothread1 \
    \
    -device virtio-net-pci,mac=9a:ee:59:a5:37:d1,id=idrNxnaX,netdev=idQJZcEy,bus=pci.0,addr=0x8  \
    -netdev tap,id=idQJZcEy,vhost=on  \
    -vnc :5  -monitor stdio \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm

steps(){

  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 2G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 3G

}