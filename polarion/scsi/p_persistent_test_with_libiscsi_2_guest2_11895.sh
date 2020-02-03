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
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  \
 -object pr-manager-helper,id=helper0,path=/var/run/qemu-pr-helper.sock \
  -blockdev driver=iscsi,pr-manager=helper0,cache.direct=on,cache.no-flush=off,node-name=protocol_node1,transport=tcp,portal=10.66.8.105,target=iqn.2016-06.qing.server:a,initiator-name=iqn.1994-05.com.redhat:dell-per740xd-01 \
  -blockdev driver=raw,node-name=drive-virtio-disk0,file=protocol_node1 \
  -device scsi-block,id=data1,drive=drive-virtio-disk0,rerror=stop,werror=stop,bootindex=1 \
  \
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
  -iscsi initiator-name=iqn.1994-05.com.redhat:dell-per740xd-01 \
  -drive file=iscsi://10.66.8.105:3260/iqn.2016-06.qing.server:b/0,if=none,id=drive-virtio-disk1,format=raw,cache=none \
  -device scsi-block,drive=drive-virtio-disk1,rerror=stop,werror=stop,id=data2,bootindex=2  \


   sg_persist --out --release --param-rk=123abc --prout-type=1 /dev/mapper/mpatha
   sg_persist -r /dev/mapper/mpatha

   sg_persist --out --reserve --param-rk=123abc --prout-type=1 /dev/mapper/mpatha
   sg_persist --out --reserve --param-rk=123abc --prout-type=1 /dev/sda
   sg_persist -r /dev/mapper/mpatha

#Guest
sg_persist --out --register --param-sark=123abc /dev/sdb
sg_persist --out --reserve --param-rk=123abc --prout-type=1 /dev/sdb
sg_persist -r /dev/sdb
 sg_persist --out --release --param-rk=123abc --prout-type=1 /dev/sdb

LIO-ORG   mpath-disk0       4.0
  Peripheral device type: disk
  PR generation=0x2, Reservation follows:
    Key=0x123abc
    scope: LU_SCOPE,  type: Write Exclusive


  {"execute": "qmp_capabilities"}


}
