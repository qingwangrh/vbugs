dd if=/dev/urandom of=/tmp/orig bs=10M count=1;mkisofs -o /tmp/orig.iso /tmp/orig;
cp -rf /tmp/orig.iso /tmp/orig2.iso;cp -rf /tmp/orig.iso /tmp/new.iso;

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 1024  \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Client',+kvm_pv_unhalt \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,x-iops-total=50,id=group1 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel810-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    \
    -device virtio-net-pci,mac=9a:49:aa:b7:2e:1c,id=idj0CJgn,netdev=idvNAmuP,bus=pci.0,addr=0x5  \
    -netdev tap,id=idvNAmuP,vhost=on \
    -blockdev node-name=file_cd1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/tmp/orig.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=raw_cd1,driver=raw,file=file_cd1,read-only=on,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=throttle,throttle-group=group1,file=raw_cd1 \
    -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on  \
    \
    -blockdev node-name=file_cd2,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/tmp/orig2.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=raw_cd2,driver=raw,file=file_cd2,read-only=on,cache.direct=on,cache.no-flush=off \
    -device scsi-cd,id=cd2,drive=raw_cd2,write-cache=on  \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -qmp tcp:0:5955,server,nowait \


steps(){

   -blockdev node-name=file_image2,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/data2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=raw_image2,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image2 \
    -blockdev node-name=drive_image2,driver=throttle,throttle-group=group1,file=raw_image2,cache.direct=on,cache.no-flush=off \
    -device scsi-hd,id=image2,drive=drive_image2,write-cache=on  \

  {"execute":"qmp_capabilities"}
  {'execute': 'qom-get', 'arguments': {'path': 'group1', 'property': 'limits'}}


  {"execute": "blockdev-open-tray", "arguments": {"id": "cd1", "force": true}}

  {'execute': 'blockdev-change-medium', 'arguments': {'id': 'cd1', 'filename': '/tmp/new.iso','format':"raw"}, 'id': '8bKaaP5R'}

  {'execute': 'blockdev-remove-medium', 'arguments': {'id': 'cd1'}, 'id': 'c9xqPEHg'}

  {'execute': 'blockdev-insert-medium', 'arguments': {'id': 'cd1', 'filename': '/tmp/new.iso',"node-name":"drive_cd1"}, 'id': '8bKaaP5R'}

  {"execute": "blockdev-close-tray", "arguments": {"id": "cd1"}}

  {"execute":"query-block"}
}