
#cache writeback
/usr/libexec/qemu-kvm \
  -name src_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,bus=pcie.0 \
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
  -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-7,addr=0x0 \
  -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/images/data2.qcow2,node-name=data_disk \
  -blockdev driver=qcow2,node-name=disk1,file=data_disk \
  -device scsi-hd,drive=disk1,bus=virtio_scsi_pci0.0,id=data_disk \
  \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev node-name=host_device_stg0,driver=host_device,cache.direct=off,cache.no-flush=off,filename=/dev/sg5 \
  -blockdev node-name=drive_stg0,driver=raw,cache.direct=off,cache.no-flush=off,file=host_device_stg0 \
  -device scsi-generic,id=stg0,drive=drive_stg0,bus=scsi1.0 \
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \



steps() {
  #cache writeback
  #Host
  sg_map

  #Guest
  sg_dd if=/dev/zero of=/dev/sg2 bs=512 count=1 blk_sgio=1
  sg_dd if=/dev/sg2 of=/dev/null bs=512 count=1 blk_sgio=1

}

