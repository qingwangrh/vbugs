/usr/libexec/qemu-kvm -enable-kvm \
  -m 4G -M accel=kvm,memory-backend=mem \
  -nodefaults \
  -vga qxl \
  -smp 4 \
  -object memory-backend-memfd,id=mem,size=4G,share=on \
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
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_image1 \
  -device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=0 \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=data1 \
  -device virtio-blk-pci,id=blk1,drive=data1,bootindex=1 \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data2.qcow2,node-name=data2 \
  -device virtio-blk-pci,id=blk2,drive=data2,bootindex=2 \
  -vnc :5 \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait

  steps() {

qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data2.qcow2 2G

  #nc -U /tmp/qmp.sock
  #loging qemu qmp
  {"execute":"qmp_capabilities"}
  {"execute": "device_del", "arguments": {"id": "blk2"}}

  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "blk2", "drive": "data2"}}

  }
