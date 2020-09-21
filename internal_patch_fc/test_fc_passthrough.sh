/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine pc \
  -nodefaults \
  -device VGA,bus=pci.0,addr=0x2 \
  -m 8096 \
  -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2 \
  -cpu 'Cascadelake-Server-noTSX',+kvm_pv_unhalt \
  -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
  -blockdev node-name=host_device_stg,driver=host_device,aio=native,filename=/dev/mapper/mpatha,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_stg,driver=raw,cache.direct=on,cache.no-flush=off,file=host_device_stg \
  -device scsi-block,id=stg,drive=drive_stg,rerror=stop,werror=stop \
  -device virtio-net-pci,mac=9a:a3:b2:e0:6b:62,id=idM587du,netdev=idBNjt3C,bus=pci.0,addr=0x5 \
  -netdev tap,id=idBNjt3C,vhost=on \
  -vnc :5 \
  -rtc base=utc,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm -monitor stdio \
  -qmp tcp:0:5955,server,nowait

steps() {

  #guest
  parted -s "/dev/sdb" mklabel gpt
  parted -s "/dev/sdb" mkpart primary 0M 61440.0M
  partprobe /dev/sdb

  #host
  dd if=/dev/zero of=/dev/mapper/mpatha bs=1M count=1000

}
