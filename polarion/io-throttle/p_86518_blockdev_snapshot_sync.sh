qemu-img create -f raw /home/kvm_autotest_root/images/stg1.raw 11G
#qemu-img create -f raw /home/kvm_autotest_root/images/stg2.raw 12G
#qemu-img create -f raw /home/kvm_autotest_root/images/stg3.raw 13G

/usr/libexec/qemu-kvm \
  -name 'throttle-vm1' \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x1 \
  -device pvpanic,ioport=0x505,id=idZcGD6F \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-3,addr=0x0,iothread=iothread0 \
  -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-4,addr=0x0 \
  -object throttle-group,x-iops-total=50,x-iops-total-max=60,x-iops-total-max-length=10,id=group2 \
  -object throttle-group,id=group1,x-iops-total=50 \
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_img \
  -blockdev driver=qcow2,node-name=os_drive,file=os_img \
  -device scsi-hd,drive=os_drive,bus=scsi0.0,id=os_disk \
  \
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.raw \
  -blockdev driver=raw,node-name=fmt_stg1,file=file_stg1 \
  -blockdev driver=throttle,throttle-group=group1,node-name=drive_stg1,file=fmt_stg1 \
  -device virtio-blk-pci,drive=drive_stg1,id=data1,bus=pcie.0-root-port-7,addr=0x0 \
  \
  -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idGRsMas,vhost=on \
  -m 4G \
  -vnc :5 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -enable-kvm \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait

steps() {
  #issue
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie.0-root-port-6,addr=0x0 \
  \
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg1,filename=/home/kvm_autotest_root/images/stg1.raw \
  -blockdev driver=raw,node-name=fmt_stg1,file=file_stg1 \
  -blockdev driver=throttle,throttle-group=group1,node-name=drive_stg1,file=fmt_stg1 \
  -device virtio-blk-pci,drive=drive_stg1,id=data1,bus=pcie.0-root-port-7,addr=0x0 \
  #ok, it looks still have issue
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_img \
  -blockdev driver=qcow2,node-name=os_drive,file=os_img \
  -device scsi-hd,drive=os_drive,bus=scsi0.0,id=os_disk \
  \
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,node-name=file_stg2,filename=/home/kvm_autotest_root/images/stg2.raw \
  -blockdev driver=raw,node-name=drive_stg2,file=file_stg2 \
  -device virtio-blk-pci,drive=drive_stg2,id=data2,bus=pcie.0-root-port-7,addr=0x0 \
  -drive \
  id=drive_image3,if=none,snapshot=off,aio=native,cache=none,format=raw,file=/home/kvm_autotest_root/images/stg3.raw,iops=100 \
  -device scsi-hd,id=image3,drive=drive_image3 \
  -device \
  pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0

  -object throttle-group,id=foo,x-iops-total=50 \
    -object throttle-group,x-iops-total=50,x-iops-total-max=60,x-iops-total-max-length=10,id=group1

  For drive:
  {"execute": "qmp_capabilities"}
  {"execute":"blockdev-snapshot-sync","arguments":
  }{"device":"drive_image3","snapshot-file":"image3-snap"}

  #ok

  For blockdev

  {"execute": "qmp_capabilities"}
  {"execute": "blockdev-create", "arguments": {"options": {"driver": "file", "filename": "/home/kvm_autotest_root/images/sn1.qcow2", "size": 11811160064}, "job-id": "file_sn1"}, "id": "lI1v3pjM"}
  {"execute": "query-jobs", "id": "eknDwEbD"}
  {"execute": "job-dismiss", "arguments": {"id": "file_sn1"}, "id": "1pF2hDBK"}
  {"execute": "blockdev-add", "arguments": {"node-name": "file_sn1", "driver": "file", "filename": "/home/kvm_autotest_root/images/sn1.qcow2", "aio": "threads", "auto-read-only": true, "discard": "unmap"}, "id": "c0PkSEKH"}

  {"execute": "blockdev-create", "arguments": {"options": {"driver": "qcow2", "file": "file_sn1", "size": 11811160064}, "job-id": "drive_sn1"}, "id": "mHZQGs67"}
  {"execute": "query-jobs", "id": "eknDwEbD"}

  {"execute": "job-dismiss", "arguments": {"id": "drive_sn1"}, "id": "8pDXDcDM"}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_sn1", "driver": "qcow2", "file": "file_sn1", "read-only": false}, "id": "Kib3C8EH"}


  {"execute": "blockdev-snapshot", "arguments": {"node": "drive_stg1", "overlay": "drive_sn1"}, "id": "7UAdhqLR"}

  fio --filename=/dev/vdb --direct=1 --rw=randrw --bs=4k --size=500M --name=test --iodepth=1 --runtime=30

  fio --direct=1 --rw=randrw --bs=4k --name=test --iodepth=1 --runtime=120 --filename=/dev/vdb
  # not throttle
  {"execute": "qmp_capabilities"}
  {"execute": "blockdev-create", "arguments": {"options": {"driver": "file", "filename": "/home/kvm_autotest_root/images/sn2.qcow2", "size": 2147483648}, "job-id": "file_sn2"}, "id": "lI1v3pjM"}
  {"execute": "query-jobs", "id": "eknDwEbD"}
  {"execute": "job-dismiss", "arguments": {"id": "file_sn2"}, "id": "1pF2hDBK"}
  {"execute": "blockdev-add", "arguments": {"node-name": "file_sn2", "driver": "file", "filename": "/home/kvm_autotest_root/images/sn2.qcow2", "aio": "threads", "auto-read-only": true, "discard": "unmap"}, "id": "c0PkSEKH"}

  {"execute": "blockdev-create", "arguments": {"options": {"driver": "qcow2", "file": "file_sn2", "size": 2147483648}, "job-id": "drive_sn2"}, "id": "mHZQGs67"}
  {"execute": "query-jobs", "id": "eknDwEbD"}
  {"execute": "job-dismiss", "arguments": {"id": "drive_sn2"}, "id": "8pDXDcDM"}

  {"execute": "blockdev-add", "arguments": {"node-name": "drive_sn2", "driver": "qcow2", "file": "file_sn2", "read-only": false}, "id": "Kib3C8EH"}

  {"execute": "blockdev-snapshot", "arguments": {"node": "drive_stg2", "overlay": "drive_sn2"}, "id": "Z8BFNiEr"}

}
