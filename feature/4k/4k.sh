qemu-img create -f qcow2 /home/kvm_autotest_root/images/check_block_size_image.qcow2 20G


/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 4096  \
    -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=1,write-cache=on,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/check_block_size_image.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg,drive=drive_stg,logical_block_size=4096,physical_block_size=4096,write-cache=on,serial=TARGET_DISK0,bus=pcie-root-port-3,addr=0x0,iothread=iothread1 \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-net-pci,mac=9a:7f:28:40:36:ff,id=idoWTFBi,netdev=idUCHgVq,bus=pcie-root-port-4,addr=0x0  \
    -netdev tap,id=idUCHgVq,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/linux/RHEL7.9-Server-x86_64.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,write-cache=on,bus=ide.0,unit=0  \
    \
    -vnc :5 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=6


  steps(){
#only installation need them
    -kernel '/home/kvm_autotest_root/images/rhel79-64/vmlinuz'  \
    -append 'inst.sshd ksdevice=link inst.repo=cdrom:/dev/sr0 inst.ks=cdrom:/dev/sr1:/ks.cfg nicdelay=60 biosdevname=0 net.ifnames=0 console=ttyS0,115200 console=tty0'  \
    -initrd '/home/kvm_autotest_root/images/rhel79-64/initrd.img'  \
  }