#!/usr/bin/env bash

/usr/libexec/qemu-kvm \
  -name testvm \
  -machine q35 \
  -m 8G \
  -smp 8 \
  -cpu host,vmx,+kvm_pv_unhalt \
  -device \
  pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-3,addr=0x0 \
  -blockdev node-name=host_device_stg,driver=host_device,aio=native,filename=/dev/mapper/mpatha,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_stg,driver=raw,cache.direct=on,cache.no-flush=off,file=host_device_stg \
  -device scsi-block,id=stg,drive=drive_stg,rerror=report,werror=report \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:ad:20:19:2a:c8,id=idaRAD4c,netdev=idqYCTOT,bus=pcie.0-root-port-4,addr=0x0 \
  -netdev tap,id=idqYCTOT,vhost=on \
  -vnc :5 \
  -monitor stdio \
  -qmp tcp:0:5955,server=on,wait=off \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/linux/RHEL-8.4.0-20210503.1-x86_64-dvd1.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on \
  -rtc base=utc,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=d,strict=off

steps() {
  #scsi-block not work for fc but work for iscsi
  #scci-hd workd
  echo
  #ok
  47:00.0 Fibre Channel: QLogic Corp. ISP2532-based 8Gb Fibre Channel to PCI Express HBA (rev 02)
  #failed
  65:00.0 Fibre Channel: Emulex Corporation LPe15000/LPe16000 Series 8Gb/16Gb Fibre Channel Adapter (rev 30)

}
