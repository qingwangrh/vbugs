/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1 \
    -m 8096  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -object iothread,id=iothread2 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-0.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,iothread=iothread0,bus=pcie.0-root-port-3,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:ca:eb:71:ee:b9,id=idkXCdFR,netdev=idwaVNIA,bus=pcie.0-root-port-4,addr=0x0  \
    -netdev tap,id=idwaVNIA,vhost=on \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :10  \
    -qmp tcp:0:5950,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -enable-kvm -monitor stdio \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0 \

teststep(){
{'execute': 'qmp_capabilities'}
{'execute': 'stop'}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/data0.raw", "cache": {"direct": true, "no-flush": false}}}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "raw", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "iothread": "iothread1", "bus": "pcie_extra_root_port_0", "addr": "0x0"}}
{'execute': 'cont'}
dd if=/dev/vdb of=/dev/null bs=1k count=1000 iflag=direct && dd if=/dev/zero of=/dev/vdb bs=1k count=1000 oflag=direct
#{'execute': 'stop'}
{"execute": "device_del", "arguments": {"id": "stg0"}}
{"execute": "query-status"}

{"execute": "device_add", "arguments": {"driver": "scsi-hd", "id": "stg0", "drive": "drive_stg0", "write-cache": "on"}}
}