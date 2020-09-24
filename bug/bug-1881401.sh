# This clone to 1881404,1881405,1881406
# This only for pc?
# dd if=/dev/zero of=/home/kvm_autotest_root/images/fda.img bs=1024 count=1440
#/usr/libexec/qemu-kvm  -nographic -enable-kvm -m 100 -net none -fda fda.img -cdrom hypertrash.iso

/usr/libexec/qemu-kvm \
  -name testvm \
  -machine pc \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pci.0,addr=0x3,chassis=1 \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pci.0,chassis=2 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pci.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=pci.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=pci.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=pci.0,chassis=6 \
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=pci.0,chassis=7 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=pci.0,chassis=8 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel79-64-virtio.qcow2,node-name=drive_image1   \
  -device virtio-blk-pci,id=os_disk,drive=drive_image1,bus=pcie-root-port-2,addr=0x0,bootindex=0,serial=OS_DISK   \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=data_image1   \
  -device virtio-blk-pci,id=data_disk,drive=data_image1,bus=pcie-root-port-3,addr=0x0,bootindex=1,serial=DATA_DISK   \
  -vnc :5 \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device pcie-root-port,id=pcie-root-port-8,slot=8,chassis=8,addr=0x8,bus=pci.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b7,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp7.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial7.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0 \
  -D debug.log \
  -fda /home/kvm_autotest_root/images/fda.img