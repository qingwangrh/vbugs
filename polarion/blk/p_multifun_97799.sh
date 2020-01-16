#need generate stg disks

/usr/libexec/qemu-kvm \
  -name copy_read_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-5,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device virtio-blk-pci,id=os1,drive=drive_image1,bus=pcie.0-root-port-2,bootindex=0,multifunction=on \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.qcow2,node-name=data_image0 \
  -device virtio-blk-pci,id=data0,drive=data_image0,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
  -vnc \
  :5 \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

  {"execute": "qmp_capabilities"}

  {"execute": "blockdev-add","arguments": {"node-name":"data_disk1","driver":"file","filename":"/home/images/stg1.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk1","driver":"qcow2","file":"data_disk1"}}
  {'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'disk1','bus':'pcie.0-root-port-4','addr':'0x0.0x1','id':'data_disk1'}}

  {"execute": "blockdev-add","arguments": {"node-name":"data_disk2","driver":"file","filename":"/home/images/stg2.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk2","driver":"qcow2","file":"data_disk2"}}
  {'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'disk2','bus':'pcie.0-root-port-4','addr':'0x0.0x2','id':'data_disk2'}}

  {"execute": "blockdev-add","arguments": {"node-name":"data_disk3","driver":"file","filename":"/home/images/stg3.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk3","driver":"qcow2","file":"data_disk3"}}
  {'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'disk3','bus':'pcie.0-root-port-4','addr':'0x0.0x3','id':'data_disk3'}}

  {"execute": "blockdev-add","arguments": {"node-name":"data_disk8","driver":"file","filename":"/home/images/stg8.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk8","driver":"qcow2","file":"data_disk8"}}
  {'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'disk8','bus':'pcie.0-root-port-4','addr':'0x0','id':'data_disk8','multifunction':'on'}}

  #mulitfunction off to
  {"execute": "blockdev-add","arguments": {"node-name":"data_disk8","driver":"file","filename":"/home/images/stg8.qcow2"}}
  {"execute": "blockdev-add","arguments": {"node-name": "disk8","driver":"qcow2","file":"data_disk8"}}
  {'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'disk8','bus':'pcie.0-root-port-4','addr':'0x0','id':'data_disk8','multifunction':'off'}}

  #{"error": {"class": "GenericError", "desc": "PCI: 0.0 indicates single function, but 0.1 is already populated."}}


  {"execute":"device_del","arguments":{"id":"data_disk2"} }
  {"execute": "blockdev-del","arguments": { "node-name": "disk2"}}
  {"execute": "blockdev-del","arguments": { "node-name": "data_disk2"}}

  {"execute":"device_del","arguments":{"id":"data_disk8"} }
  {"execute": "blockdev-del","arguments": { "node-name": "disk8"}}
  {"execute": "blockdev-del","arguments": { "node-name": "data_disk8"}}

}
