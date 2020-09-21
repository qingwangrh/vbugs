/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine q35 \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
  -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x2 \
  -m 8096 \
  -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2 \
  -cpu 'Cascadelake-Server-noTSX',+kvm_pv_unhalt \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
  -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-root-port-2,addr=0x0 \
  -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
  -blockdev node-name=host_device_stg,driver=host_device,aio=native,filename=/dev/mapper/mpatha,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_stg,driver=raw,cache.direct=on,cache.no-flush=off,file=host_device_stg \
  -device scsi-block,id=stg,drive=drive_stg,rerror=stop,werror=stop \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
  -device virtio-net-pci,mac=9a:36:5c:7f:c0:86,id=idjyFAqV,netdev=idIuQkyR,bus=pcie-root-port-3,addr=0x0 \
  -netdev tap,id=idIuQkyR,vhost=on \
  -vnc :0 \
  -rtc base=utc,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm \
  -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
  -monitor stdio

steps() {

  yum install -y iscsi-initiator-utils device-mapper*
  mpathconf --enable

  cat /etc/iscsi/initiatorname.iscsi
  InitiatorName=iqn.1994-05.com.redhat:share1

  systemctl restart iscsid iscsi multipathd

  iscsiadm -m discovery -t st -p 10.66.8.105
  iscsiadm -m node -T iqn.2016-06.qing.server60:a -p 10.66.8.105:3260 -l
  iscsiadm -m node -T iqn.2016-06.qing.server60:b -p 10.66.8.105:3260 -l

}
