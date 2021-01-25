#block_hotplug.block_scsi.fmt_qcow2.default.with_plug.with_block_resize.one_pci
#block_resize issue

/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine pc \
  -nodefaults \
  -device VGA,bus=pci.0,addr=0x2 \
  -m 12288 \
  -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -object iothread,id=iothread1 \
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pci.0,addr=0x4,iothread=iothread0 \
  -device virtio-net-pci,mac=9a:c9:74:ff:a9:dc,id=idXZF3Pt,netdev=idFui7Aw,bus=pci.0,addr=0x5 \
  -netdev tap,id=idFui7Aw,vhost=on \
  -vnc :5 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio

steps() {

#
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 10G


  {"execute":"qmp_capabilities"}
  {"execute": "device_add", "arguments": {"id": "virtio_scsi_pci0", "driver": "virtio-scsi-pci", "bus": "pci.0", "addr": "0x6", "iothread": "iothread1"}, "id": "ObvkQjyd"}
  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "auto-read-only": true, "discard": "unmap", "aio": "threads", "filename": "/home/kvm_autotest_root/images/storage0.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "Jaw90cpP"}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "read-only": false, "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}, "id": "Jn0EUb6J"}
  {"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "serial": "TARGET_DISK0", "bus": "virtio_scsi_pci0.0"}, "id": "oiyRS0nF"}

  {"execute": "block_resize", "arguments": {"node-name": "drive_stg0", "size": 16106127360}, "id": "ZFnaEVuL"}

  {"execute": "block_resize", "arguments": {"node-name": "drive_stg0", "size": 19106127360}, "id": "ZFnaEVuL"}

}
