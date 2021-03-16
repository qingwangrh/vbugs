/usr/libexec/qemu-kvm \
  -name L1-vm \
  -machine q35 \
  -cpu host,vmx \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x3,chassis=1 \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pcie.0,chassis=2 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=pcie.0,chassis=6 \
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=pcie.0,chassis=7 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=pcie.0,chassis=8 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi-L1.qcow2,node-name=drive_image1   \
  -device scsi-hd,id=os,drive=drive_image1,bus=scsi0.0,bootindex=0,serial=OS_DISK   \
  \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=data_image1   \
  -device scsi-hd,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1,rerror=stop,werror=stop \
 \
  -vnc :5 \
  -monitor stdio \
  -m 12G \
  -device pcie-root-port,id=pcie-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b7,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -qmp tcp:0:5955,server,nowait \


steps(){
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 5G
qemu-img create -f raw /home/kvm_autotest_root/images/data1.raw 5G
-blockdev driver=raw,file.driver=host_device,file.filename=/dev/sdd,node-name=data_image1 \
-device scsi-hd,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1,rerror=stop,werror=stop \

-blockdev driver=raw,file.driver=file,file.filename=/home/kvm_autotest_root/images/data1.raw,node-name=data_image1 \
-device scsi-hd,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1,rerror=stop,werror=stop \


  -device scsi-block,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1,rerror=stop,werror=stop   \



dd of=/dev/sdb if=/dev/urandom bs=1k count=500000 oflag=direct

{"execute": "qmp_capabilities"}

{"execute": "block_resize", "arguments": {"node-name": "data_image1", "size": 6442450944 }}

{"execute": "block_resize", "arguments": {"node-name": "data_image1", "size": 7516192768 }}



}

