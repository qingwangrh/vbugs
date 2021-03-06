/usr/libexec/qemu-kvm \
  -name copy_read_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.8-Server-x86_64.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-64-virtio.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  \
  -device virtio-scsi-pci,id=virtio_scsi_pci1,bus=pcie.0-root-port-9,addr=0x0 \
  -device scsi-cd,bus=virtio_scsi_pci1.0,id=none \
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

  {"execute": "qmp_capabilities"}

  {"execute":"blockdev-open-tray","arguments":{"id":"none"}}
  {"execute":"blockdev-remove-medium","arguments":{"id":"none"}}

  {"execute": "blockdev-add","arguments": {"node-name": "file_none","driver": "file", "filename": "/home/kvm_autotest_root/iso/windows/winutils.iso","read-only": true}}
  {"execute": "blockdev-add","arguments": {"node-name": "drive_none","driver":"raw","file":"file_none","read-only": true}}

  {"execute":"blockdev-insert-medium","arguments":{"id":"none","node-name":"drive_none"}}

  {"execute": "query-block"}

  {"execute":"blockdev-close-tray", "arguments": {"id": "none"}}

  {"execute":"blockdev-change-medium","arguments":{"id": "none","filename": "/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-172.iso", "format": "raw"}}

  {"execute": "query-block"}

}
