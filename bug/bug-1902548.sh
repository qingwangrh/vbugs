#!/usr/bin/env bash

/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -sandbox on \
  -machine pc \
  -nodefaults \
  -device VGA,bus=pci.0,addr=0x2 \
  -m 8096 \
  -smp 60,maxcpus=60,cores=30,threads=1,sockets=2  \
  -cpu 'host' \
  -chardev socket,server,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpmonitor1,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -chardev socket,server,id=chardev_serial0,path=/var/tmp/serial-serial0,nowait \
  -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pci.0,addr=0x4 \
  -device virtio-net-pci,mac=9a:ac:2f:f2:95:8d,id=idT9IhMN,netdev=idpSaD7d,bus=pci.0,addr=0x5 \
  -netdev tap,id=idpSaD7d,vhost=on \
  -rtc base=utc,clock=host \
  -boot menu=off,order=cdn,once=c,strict=off \
  -enable-kvm \
  -vnc :5 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -device pcie-root-port,id=pcie_extra_root_port_0,bus=pci.0 \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait \
  -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0

steps() {

  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_0.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_1.qcow2 2G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_2.qcow2 3G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_3.qcow2 4G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_4.qcow2 5G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_5.qcow2 6G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_6.qcow2 7G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_7.qcow2 8G

  {"execute":"qmp_capabilities"}
  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_0.qcow2", "node-name": "file_block-id4fcjgc"}, "id": "DGW91isx"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-id4fcjgc", "file": "file_block-id4fcjgc"}, "id": "fnTQd7g4"}
  {"execute": "device_add", "arguments": {"id": "block-id4fcjgc", "driver": "virtio-blk-pci", "drive": "block-id4fcjgc"}, "id": "zw5pdBkE"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_1.qcow2", "node-name": "file_block-idlxYVyb"}, "id": "MqnzZxWZ"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-idlxYVyb", "file": "file_block-idlxYVyb"}, "id": "zR71NhES"}
  {"execute": "device_add", "arguments": {"id": "block-idlxYVyb", "driver": "virtio-blk-pci", "drive": "block-idlxYVyb"}, "id": "kYsG5im6"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_2.qcow2", "node-name": "file_block-id1l86Qo"}, "id": "noa1ORcI"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-id1l86Qo", "file": "file_block-id1l86Qo"}, "id": "eLRzZjRq"}
  {"execute": "device_add", "arguments": {"id": "block-id1l86Qo", "driver": "virtio-blk-pci", "drive": "block-id1l86Qo"}, "id": "sPK74ki2"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_3.qcow2", "node-name": "file_block-iddYeNtw"}, "id": "Kcm9lCyp"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-iddYeNtw", "file": "file_block-iddYeNtw"}, "id": "ld8F8l1T"}
  {"execute": "device_add", "arguments": {"id": "block-iddYeNtw", "driver": "virtio-blk-pci", "drive": "block-iddYeNtw"}, "id": "SWBGpgPc"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_4.qcow2", "node-name": "file_block-idxDBhNZ"}, "id": "xJgSCb90"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-idxDBhNZ", "file": "file_block-idxDBhNZ"}, "id": "I51sqQWV"}
  {"execute": "device_add", "arguments": {"id": "block-idxDBhNZ", "driver": "virtio-blk-pci", "drive": "block-idxDBhNZ"}, "id": "rr6RTpJJ"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_5.qcow2", "node-name": "file_block-iddGGL3b"}, "id": "8iMWOGKi"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-iddGGL3b", "file": "file_block-iddGGL3b"}, "id": "vKpwTYMr"}
  {"execute": "device_add", "arguments": {"id": "block-iddGGL3b", "driver": "virtio-blk-pci", "drive": "block-iddGGL3b"}, "id": "X7DMQcji"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_6.qcow2", "node-name": "file_block-idAMfZD0"}, "id": "enmXS1pU"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-idAMfZD0", "file": "file_block-idAMfZD0"}, "id": "1IRPcfKE"}
  {"execute": "device_add", "arguments": {"id": "block-idAMfZD0", "driver": "virtio-blk-pci", "drive": "block-idAMfZD0"}, "id": "KfvoCWwf"}

  {"execute": "blockdev-add", "arguments": {"driver": "file", "filename": "/home/kvm_autotest_root/images/storage_7.qcow2", "node-name": "file_block-id3WjYqy"}, "id": "svGjzLQU"}
  {"execute": "blockdev-add", "arguments": {"driver": "qcow2", "node-name": "block-id3WjYqy", "file": "file_block-id3WjYqy"}, "id": "oqKsFhNv"}
  {"execute": "device_add", "arguments": {"id": "block-id3WjYqy", "driver": "virtio-blk-pci", "drive": "block-id3WjYqy"}, "id": "5NgfMCsL"}

  #failed on add storage_6 and storage_7 on ppc
  #qemu-kvm: virtio_bus_set_host_notifier: unable to init event notifier: Too many open files (-24)
  #virtio-blk failed to set host notifier (-24)
  #qemu-kvm: virtio_bus_start_ioeventfd: failed. Fallback to userspace (slower).
  #qemu-kvm: virtio-blk failed to set guest notifier (-24), ensure -accel kvm is set.
  #qemu-kvm: virtio_bus_start_ioeventfd: failed. Fallback to userspace (slower).

}
