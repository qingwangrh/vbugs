qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage1.qcow2 2G

#OS=rhel830
OS=rhel79

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
    -cpu 'Cascadelake-Server-noTSX',+kvm_pv_unhalt \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/${OS}-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg0,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage0.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg0,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg0,drive=drive_stg0,bootindex=1,write-cache=on,serial=TARGET_DISK0,discard=on,write-zeroes=on,bus=pcie-root-port-3,addr=0x0,iothread=iothread1 \
    \
    -blockdev node-name=file_stg1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg1 \
    -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x1.0x6,bus=pcie.0,chassis=6 \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bootindex=2,write-cache=on,serial=TARGET_DISK1,discard=off,write-zeroes=off,bus=pcie-root-port-6,addr=0x0,iothread=iothread1 \
    \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-net-pci,mac=9a:7f:28:40:36:ff,id=id5TeXGO,netdev=idbCulQz,bus=pcie-root-port-4,addr=0x0  \
    -netdev tap,id=idbCulQz,vhost=on  \
     -vnc :5 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=7 \

steps(){


  #have issue on rhel7.9 no issue on rhel.8.3.0
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage0.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage1.qcow2 2G
  #check qtree
  discard = true
  write-zeroes = true

  #In guest, check if discard works:
  # blkdiscard /dev/vdb && echo "PASS" || echo "FAIL"


}