
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 1G

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 16,maxcpus=16,cores=8,threads=1,dies=1,sockets=2  \
    -cpu 'Broadwell',hv_stimer,hv_synic,hv_vpindex,hv_relaxed,hv_spinlocks=0xfff,hv_vapic,hv_time,hv_frequencies,hv_runtime,hv_tlbflush,hv_reenlightenment,hv_stimer_direct,hv_ipi,+kvm_pv_unhalt \
    \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-ehci,id=ehci,bus=pcie.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:0a:02:af:3a:3e,id=idahbxS8,netdev=iduVJQz1,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=iduVJQz1,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x4,chassis=5 \
    -device pcie-root-port,id=pcie_extra_root_port_1,addr=0x4.0x1,bus=pcie.0,chassis=6 \
    -device pcie-root-port,id=pcie_extra_root_port_2,addr=0x4.0x2,bus=pcie.0,chassis=7 \
    -device pcie-root-port,id=pcie_extra_root_port_3,addr=0x4.0x3,bus=pcie.0,chassis=8 \
    -device pcie-root-port,id=pcie_extra_root_port_4,addr=0x4.0x4,bus=pcie.0,chassis=9 \
    -device pcie-root-port,id=pcie_extra_root_port_5,addr=0x4.0x5,bus=pcie.0,chassis=10 \
    -device pcie-root-port,id=pcie_extra_root_port_6,addr=0x4.0x6,bus=pcie.0,chassis=11 \
    -device pcie-root-port,id=pcie_extra_root_port_7,addr=0x4.0x7,bus=pcie.0,chassis=12 \
    \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \


steps(){
#run diskmanager->rescan or device management, do "Scan for hardware changed" in guest then do rescan

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 1G

{'execute':'qmp_capabilities'}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg2", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/stg2.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "TFY8954S"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg2", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg2"}, "id": "5tbjqDdX"}
{"execute": "device_add", "arguments": {"id": "virtio_scsi_pci2", "driver": "virtio-scsi-pci", "bus": "pcie_extra_root_port_1", "addr": "0x0", "iothread": "iothread1"}, "id": "Waeeqijg"}
{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg2", "bus": "virtio_scsi_pci2.0", "drive": "drive_stg2", "write-cache": "on"}, "id": "Zw8FL5Zl"}



{"execute":"device_del","arguments":{"id":"stg2"}}

{"execute":"device_del","arguments":{"id":"virtio_scsi_pci2"}}

}