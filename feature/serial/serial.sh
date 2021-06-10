qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data3.qcow2 3G

/usr/libexec/qemu-kvm \
  -name testvm \
  -machine q35 \
  -m 8G \
  -smp 8 \
  -cpu host,vmx,+kvm_pv_unhalt \
  -device qemu-xhci,id=usb1 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x3,chassis=1 \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pcie.0,chassis=2 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=pcie.0,chassis=6 \
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=pcie.0,chassis=7 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=pcie.0,chassis=8  \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=drive_image1   \
  -device scsi-hd,id=os,drive=drive_image1,bus=scsi0.0,bootindex=0,serial=OS_DISK   \
  \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=data_image1   \
  -device scsi-hd,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1,serial=0-1234567890-123456789-1234567890-abcdefg   \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data2.qcow2,node-name=data_image2   \
  -device scsi-hd,id=data2,drive=data_image2,bus=scsi0.0,bootindex=2,device_id=1-1234567890-123456789-1234567890-abcdefg   \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data3.qcow2,node-name=data_image3   \
  -device virtio-blk-pci,id=data3,drive=data_image3,bus=pcie-root-port-3,bootindex=3,serial=2-1234567890-123456789-1234567890-abcdefg   \
  -vnc :5 \
  -monitor stdio \
  -qmp tcp:0:5955,server=on,wait=off \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b7,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie-root-port-7 \
  -netdev tap,id=idxgXAlm \
  -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp7.log,server=on,wait=off \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -chardev file,path=/var/tmp/monitor-serial7.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0 \
  -D debug.log \
  -boot menu=on,reboot-timeout=1000 \
   \





steps() {
  #only installation need them
  {"execute": "qmp_capabilities"}

  {"execute": "device_del", "arguments": {"id": "data3"}}

  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "data3", "drive": "data_image3", "bus": "pci.0", "acpi-index": "5"}}

}
