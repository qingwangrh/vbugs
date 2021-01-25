/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device vmcoreinfo \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 4G  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,indirect_desc=off,iothread=iothread0 \
    \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:b4:f3:5b:d1:3b,id=idW8iTp6,netdev=idc5R1AE,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idc5R1AE,vhost=on  \
    -vnc :5  \
    -qmp tcp:0:5955,server,nowait \
    -monitor stdio \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \




steps(){
  #

  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,indirect_desc=off,iothread=iothread0 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
#when indirect_desc=off
#It will crash on
#Red Hat Enterprise Linux release 8.4 Beta (Ootpa)
#4.18.0-250.el8.dt4.x86_64
#qemu-kvm-common-4.2.0-37.module+el8.4.0+8837+c89bcfe6.x86_64
#It very slow on
#Red Hat Enterprise Linux release 8.3 (Ootpa)
#4.18.0-240.el8.x86_64
#qemu-kvm-common-5.1.0-14.module+el8.3.0+8790+80f9c6d8.1.x86_64

}