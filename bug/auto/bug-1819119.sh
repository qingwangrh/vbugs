/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8G  \
    \
    -device pvpanic,ioport=0x505,id=idkIeQsN \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-root-port-2,addr=0x0 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:94:98:94:81:a4,id=idrZiGRI,netdev=id3qIqB8,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=id3qIqB8,vhost=on \
    -blockdev node-name=null-co_none,driver=null-co,read-only=on \
    -blockdev node-name=drive_none,driver=raw,read-only=on,file=null-co_none \
    -device scsi-cd,id=none,drive=drive_none  \
    -vnc :6  \
    -qmp tcp:0:5956,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
    -monitor stdio


steps(){
#question
#manully operation succeed. bug failed on automation

    echo
#guest
cat /sys/block/sr0/size

#host
dd if=/dev/urandom of=orig.iso bs=1M count=100
mkisofs -o /home/kvm_autotest_root/images/orig.iso orig.iso
rm -rf orig.iso

#qmp
{"execute": "qmp_capabilities"}
{'execute': 'blockdev-change-medium', 'arguments': {'id': 'none', 'filename': '/home/kvm_autotest_root/images/orig.iso'}, 'id': 'RoCZe4QL'}

}
