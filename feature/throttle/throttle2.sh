 qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 11G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 12G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 13G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 14G

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 2048  \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2  \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,x-bps-total=1638400,x-iops-size=4096,x-iops-total=40,id=group1 \
    -object throttle-group,x-bps-total=2048000,x-iops-total=50,id=group2 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -blockdev node-name=file_stg1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg1,driver=qcow2,file=file_stg1,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=qcow2_stg1 \
    -device scsi-hd,id=stg1,drive=drive_stg1,write-cache=on,serial=TARGET_DISK1 \
    -blockdev node-name=file_stg2,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg2,driver=qcow2,file=file_stg2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=throttle,throttle-group=group1,file=qcow2_stg2 \
    -device scsi-hd,id=stg2,drive=drive_stg2,write-cache=on,serial=TARGET_DISK2 \
    -blockdev node-name=file_stg3,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg3.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg3,driver=qcow2,file=file_stg3,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg3,driver=throttle,throttle-group=group2,file=qcow2_stg3 \
    -device scsi-hd,id=stg3,drive=drive_stg3,write-cache=on,serial=TARGET_DISK3 \
    -blockdev node-name=file_stg4,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg4.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg4,driver=qcow2,file=file_stg4,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg4,driver=throttle,throttle-group=group2,file=qcow2_stg4 \
    -device scsi-hd,id=stg4,drive=drive_stg4,write-cache=on,serial=TARGET_DISK4 \
    -device virtio-net-pci,mac=9a:c0:0c:1b:16:0f,id=idwi9T4y,netdev=idO0GYFF,bus=pci.0,addr=0x5  \
    -netdev tap,id=idO0GYFF,vhost=on  \
    -vnc :5 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm



  steps(){
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 11G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 12G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 13G
    qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 14G

-object throttle-group,x-iops-read-max=30,x-iops-read=20,x-iops-read-max-length=10,x-iops-write-max=30,x-iops-write=20,x-iops-write-max-length=10,id=group2 \

{"execute":"qmp_capabilities"}
{'execute': 'qom-get', 'arguments': {'path': 'group5', 'property': 'limits'}}


  }
