/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine pc \
  -nodefaults \
  -device VGA,bus=pci.0,addr=0x2 \
  -m 16000 \
  -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2 \
  -device pvpanic,ioport=0x505,id=idWW4fRE \
  -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
  -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-3-64-virtio-scsi.raw,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=raw,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on \
  -device virtio-net-pci,mac=9a:7f:65:c9:ec:b8,id=idCBhCiy,netdev=id1uqNcV,bus=pci.0,addr=0x5 \
  -netdev tap,id=id1uqNcV,vhost=on \
  -device virtio-scsi-pci,id=virtio_scsi_pci1,bus=pci.0,addr=0x6 \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :10 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm -monitor stdio \
  -qmp tcp:0:5956,server,nowait

func() {
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 2G

  {'execute': 'qmp_capabilities'}
  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/storage0.qcow2", "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}}
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pci.0", "addr": "0x8"}}

  #ok
  -drive id=drive_image1,if=none,format=raw,file=/home/kvm_autotest_root/images/win2019-3-64-virtio-scsi.raw \
  -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,write-cache=on

  #ok
  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,addr=0x7,bus=pci.0 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-3-64-virtio-scsi.raw,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=raw,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie.0-root-port-7

}
