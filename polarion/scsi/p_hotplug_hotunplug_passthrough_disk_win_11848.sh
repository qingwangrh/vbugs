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
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.qcow2,node-name=data_image1 \
  -device virtio-blk-pci,id=data1,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \

  {"execute": "qmp_capabilities"}

  {"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"virtio_scsi_pci1","bus":"pcie.0-root-port-5","addr":"0x0"}}
  {"execute": "blockdev-add","arguments": {"node-name": "data_disk","driver": "host_device", "filename": "/dev/sdd"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk1","driver":"raw","file":"data_disk"}}
  {"execute":"device_add","arguments":{"driver":"scsi-block","drive":"disk1","id":"data_disk","bus":"virtio_scsi_pci1.0"}}

  {"execute":"device_del","arguments":{"id":"data_disk"}}
  {"execute": "blockdev-del","arguments": {"node-name": "disk1"}}
  {"execute": "blockdev-del","arguments": {"node-name": "data_disk"}}
  {"execute":"device_del","arguments":{"id":"virtio_scsi_pci1"}}

  #drive

  #{"execute":"__com.redhat_drive_add", "arguments": {"file":"/dev/sdb","format":"raw","id":"drive-scsi-disk1"}}

  {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive-scsi-disk1,if=none,snapshot=off,aio=native,cache=none,format=raw,file=/dev/sdd"}}
  {"execute":"device_add","arguments":{"driver":"virtio-scsi-pci","id":"scsi1","num_queues":"4","bus":"pcie.0-root-port-5"}}
  {"execute":"device_add","arguments":{"driver":"scsi-block","drive":"drive-scsi-disk1","id":"scsi-disk1"}}

  {"execute":"device_del","arguments":{"id":"scsi-disk1"}}
  {"execute":"device_del","arguments":{"id":"scsi1"}}

}
