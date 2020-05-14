/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -cpu 'Opteron_G5',+kvm_pv_unhalt \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:dc:cb:1a:e1:95,id=idIzPE33,netdev=idkBoHoI,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idkBoHoI,vhost=on  \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/tmp/orig.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0  \
    -vnc :6  \
    -qmp tcp:0:5956,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
    -monitor stdio



#nullcd(){
#
# /usr/libexec/qemu-kvm \
#    -name 'avocado-vt-vm1'  \
#    -sandbox on  \
#    -machine q35 \
#    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
#    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
#    -nodefaults \
#    -device VGA,bus=pcie.0,addr=0x2 \
#    -m 8G  \
#    \
#    -device pvpanic,ioport=0x505,id=idkIeQsN \
#    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
#    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
#    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
#    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
#    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-root-port-2,addr=0x0 \
#    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
#    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
#    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
#    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
#    -device virtio-net-pci,mac=9a:94:98:94:81:a4,id=idrZiGRI,netdev=id3qIqB8,bus=pcie-root-port-3,addr=0x0  \
#    -netdev tap,id=id3qIqB8,vhost=on \
#    -blockdev node-name=null-co_none,driver=null-co,read-only=on \
#    -blockdev node-name=drive_none,driver=raw,read-only=on,file=null-co_none \
#    -device scsi-cd,id=none,drive=drive_none  \
#    -vnc :6  \
#    -qmp tcp:0:5956,server,nowait \
#    -rtc base=utc,clock=host,driftfix=slew  \
#    -boot menu=off,order=cdn,once=c,strict=off \
#    -enable-kvm \
#    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
#    -monitor stdio
#
#}


steps(){

#host
dd if=/dev/urandom of=orig.iso bs=1M count=100
mkisofs -o /home/kvm_autotest_root/images/orig.iso orig.iso
mkisofs -o /tmp/orig.iso orig.iso

dd if=/dev/urandom of=orig2.iso bs=1M count=200
mkisofs -o /home/kvm_autotest_root/images/orig2.iso orig2.iso
mkisofs -o /tmp/orig2.iso orig2.iso

#blockdev-change-medium case
{"execute": "qmp_capabilities"}
{'execute': 'blockdev-change-medium', 'arguments': {'id': 'none', 'filename': '/home/kvm_autotest_root/images/orig.iso'}, 'id': 'RoCZe4QL'}

/usr/libexec/qemu-kvm -enable-kvm -m 1G -device virtio-scsi -drive file=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,if=none -device scsi-hd,drive=none0 -cdrom /home/kvm_autotest_root/images/orig.iso -qmp stdio -monitor vc -vnc :0

{"execute": "qmp_capabilities"}
{'execute': 'blockdev-change-medium', 'arguments': {'device':'ide1-cd0','filename': '/home/kvm_autotest_root/images/orig2.iso'}, 'id': 'RoCZe4QL'}

{"execute": "qmp_capabilities"}
{"execute": "query-block"}

#start
{"io-status": "ok", "device": "ide1-cd0", "locked": false, "removable": true
#after mount in guest  mount /dev/cdrom /mnt
{"io-status": "ok", "device": "ide1-cd0", "locked": true, "removable": true
#then
{'execute': 'blockdev-change-medium', 'arguments': {'device':'ide1-cd0','filename': '/home/kvm_autotest_root/images/orig2.iso'}, 'id': 'RoCZe4QL'}
{"id": "RoCZe4QL", "error": {"class": "GenericError", "desc": "Device 'ide1-cd0' is locked and force was not specified, wait for tray to open and try again"}}
#guest
ls /mnt  #(nothing)
#then do again -->success
{'execute': 'blockdev-change-medium', 'arguments': {'device':'ide1-cd0','filename': '/home/kvm_autotest_root/images/orig2.iso'}, 'id': 'RoCZe4QL'}
#change to orig.iso
{'execute': 'blockdev-change-medium', 'arguments': {'device':'ide1-cd0','filename': '/home/kvm_autotest_root/images/orig.iso'}, 'id': 'RoCZe4QL'}

mount /dev/cdrom /mnt
#

#open->remove->cd

{"execute": "qmp_capabilities"}

{"execute": "blockdev-open-tray", "arguments": {"id": "cd1", "force": true}, "id": "rLYYviJo"}

{"execute": "blockdev-open-tray", "arguments": {"id": "cd1", "force": false}, "id": "rLYYviJo"}


{"execute": "blockdev-remove-medium", "arguments": {"id": "cd1"}, "id": "QDvs9JSB"}


{"execute": "qmp_capabilities"}
{'execute': 'blockdev-change-medium', 'arguments': {'id':'cd1','filename': '/tmp/orig2.iso'}, 'id': 'RoCZe4QL'}


}