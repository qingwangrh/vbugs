/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 4096  \
    -smp 4,maxcpus=4,cores=2,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Client',+kvm_pv_unhalt \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,x-iops-total=50,x-bps-total=1024000,id=group1 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0 \
    -blockdev node-name=file_data,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/workdir/kar/workspace/var/lib/avocado/data/avocado-vt/data.raw,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=raw_data,driver=raw,file=file_data,read-only=off,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_data,driver=throttle,throttle-group=group1,file=raw_data \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=data,drive=drive_data,bootindex=1,write-cache=on,serial=TARGET_DISK1,bus=pcie-root-port-3,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-net-pci,mac=9a:c3:2d:18:7f:fe,id=idbn8I6D,netdev=id7z0S2o,bus=pcie-root-port-4,addr=0x0  \
    -netdev tap,id=id7z0S2o,vhost=on  \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=6 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
