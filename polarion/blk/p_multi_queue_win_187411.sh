
qemu-img create -f qcow2 /home/images/data1.qcow2 11G
qemu-img create -f qcow2 /home/images/data2.qcow2 12G
qemu-img create -f qcow2 /home/images/data3.qcow2 13G
qemu-img create -f qcow2 /home/images/data4.qcow2 14G

/usr/libexec/qemu-kvm \
  -name copy_read_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -m 2048 \
  -smp 8 \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x2,chassis=1 \
  -device pcie-root-port,id=pcie.0-root-port-1,port=0x1,addr=0x2.0x1,bus=pcie.0,chassis=2 \
  -device pcie-root-port,id=pcie.0-root-port-2,port=0x2,addr=0x2.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie.0-root-port-3,port=0x3,addr=0x2.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie.0-root-port-4,port=0x4,addr=0x2.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie.0-root-port-5,port=0x5,addr=0x2.0x5,bus=pcie.0,chassis=6 \
  -device pcie-root-port,id=pcie.0-root-port-6,port=0x6,addr=0x2.0x6,bus=pcie.0,chassis=7 \
  -device pcie-root-port,id=pcie.0-root-port-7,port=0x7,addr=0x2.0x7,bus=pcie.0,chassis=8 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2,iothread=iothread0  \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-3,num_queues=8,iothread=iothread0  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/win2019-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0,bus=scsi0.0 \
  \
  -blockdev driver=qcow2,file.aio=threads,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.qcow2,node-name=node1 \
  -device virtio-blk-pci,id=blk_data1,drive=node1,bus=pcie.0-root-port-4,addr=0x0,bootindex=1,iothread=iothread0  \
  -blockdev driver=qcow2,file.aio=threads,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data2.qcow2,node-name=node2 \
  -device virtio-blk-pci,id=blk_data2,drive=node2,bus=pcie.0-root-port-5,addr=0x0,bootindex=2,iothread=iothread0,num-queues=8 \
  \
  -blockdev driver=qcow2,file.aio=threads,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data3.qcow2,node-name=node3 \
  -device scsi-hd,id=blk_data3,drive=node3,bus=scsi0.0,bootindex=3 \
  -blockdev driver=qcow2,file.aio=threads,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data4.qcow2,node-name=node4 \
  -device scsi-hd,id=blk_data4,drive=node4,bus=scsi1.0,bootindex=4 \
  \
  -vnc :5 \
  -monitor stdio \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp5.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial5.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \


steps(){

   #virtio_scsi
  echo

  }