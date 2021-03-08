#iommu 1903957

/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine q35,kernel-irqchip=split \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
  -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x2 \
  -m 4G \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x1.0x7,bus=pcie.0,chassis=7 \
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,iommu_platform=on,ats=on \
  \
  -blockdev node-name=file_stg0,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/storage0.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_stg0,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_stg0 \
  -device virtio-blk-pci,id=stg0,drive=drive_stg0,bootindex=1,write-cache=on,bus=pcie-root-port-3,addr=0x0,iommu_platform=on,ats=on \
  \
  -device virtio-scsi-pci,id=pcie_root_port_1,multifunction=on,bus=pcie-root-port-4,iommu_platform=on,ats=on \
  -blockdev node-name=file_stg1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/storage1.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_stg1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_stg1 \
  -device scsi-hd,id=stg1,drive=drive_stg1,bootindex=2,write-cache=on,bus=pcie_root_port_1.0 \
  \
  -device virtio-net-pci,mac=9a:58:cc:48:80:8a,id=idkuJugr,netdev=idmfKDPb,bus=pcie-root-port-7,addr=0x0,iommu_platform=on,ats=on \
  -netdev tap,id=idmfKDPb,vhost=on \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -rtc base=utc,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=c,strict=off \
  -no-hpet \
  -device intel-iommu,intremap=on,caching-mode=on,device-iotlb=on \
  -enable-kvm \
  -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=6

steps() {

  #
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 10G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage1.qcow2 11G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage2.qcow2 12G

 {"execute":"qmp_capabilities"}

#hotunplug iommu enabled device
  {'execute': 'device_del', 'arguments': {'id': 'stg0'}, 'id': 'SDclV94I'}
  #or
  {'execute': 'device_del', 'arguments': {'id': 'pcie_root_port_1'}, 'id': 'SDclV94I'}


#end

  {"execute":"qmp_capabilities"}
  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg2", "driver": "file", "auto-read-only": true, "discard": "unmap", "aio": "threads", "filename": "/home/kvm_autotest_root/images/storage2.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "Jaw90cpP"}
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg2", "driver": "qcow2", "read-only": false, "cache": {"direct": true, "no-flush": false}, "file": "file_stg2"}, "id": "Jn0EUb6J"}

  #add scsi-disk

  {"execute": "device_add", "arguments": {"id": "virtio_scsi_pci2", "driver": "virtio-scsi-pci", "bus":"pcie_extra_root_port_0", "iommu_platform":"on"}, "id": "ObvkQjyd"}
  {"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg2", "drive": "drive_stg2", "write-cache": "on", "serial": "TARGET_DISK0", "bus": "virtio_scsi_pci2.0"}, "id": "oiyRS0nF"}

  #add blk disk
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg2", "drive": "drive_stg2","bus":"pcie_extra_root_port_0","iommu_platform":"on"}, "id": "KfvoCWwf"}

  {'execute': 'device_del', 'arguments': {'id': 'stg1'}, 'id': 'SDclV94I'}

  {'execute': 'device_del', 'arguments': {'id': 'stg2'}, 'id': 'SDclV94I'}

  {'execute': 'device_del', 'arguments': {'id': 'pcie_root_port_1'}, 'id': 'SDclV94I'}

}
