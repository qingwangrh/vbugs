/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x1 \
  -m 13072 \
  -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2 \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
  -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie.0-root-port-3,addr=0x0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device virtio-net-pci,mac=9a:a6:91:a0:8f:22,id=idw2eatJ,netdev=idpFq5nx,bus=pcie.0-root-port-4,addr=0x0 \
  -netdev tap,id=idpFq5nx,vhost=on \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=native,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :6 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -enable-kvm \
  -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
  -monitor stdio \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5956,server,nowait \
  -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

  {"execute": "qmp_capabilities"}

  {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/storage0.qcow2", "cache": {"direct": true, "no-flush": false}} }
  {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"} }
  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pcie_extra_root_port_0", "addr": "0x0"}, "id": "6psvBMlU"}

  {"execute": "device_del", "arguments": {"id": "stg0"} }
  {"execute": "blockdev-del", "arguments": {"node-name": "drive_stg0"} }
  {"execute": "blockdev-del", "arguments": {"node-name": "file_stg0"} }

  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pcie_extra_root_port_0", "addr": "0x0"} }
}