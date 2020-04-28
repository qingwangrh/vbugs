modprobe -r scsi_debug; modprobe scsi_debug  lbpu=1 lbpws=1 lbprz=0
dev=`lsscsi |grep scsi|awk '{ print $6 }'`

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 2048  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-root-port-2,addr=0x0 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/rhel821-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -blockdev node-name=file_stg1,driver=host_device,aio=threads,filename=${dev},cache.direct=on,cache.no-flush=off,discard=unmap \
    -blockdev node-name=drive_stg1,driver=raw,cache.direct=on,cache.no-flush=off,file=file_stg1,discard=unmap \
    -device scsi-block,id=stg1,drive=drive_stg1 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:5b:4f:9b:c3:b0,id=idg2bFqS,netdev=ida2LQKm,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=ida2LQKm,vhost=on  \
    -vnc :6  \
    -qmp tcp:0:5956,server,nowait  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
    -device virtio-serial-pci,disable-legacy=on,disable-modern=off,id=virtio-serial0 \
    -chardev socket,path=/tmp/qga.sock,server,nowait,id=qga0 \
    -device virtserialport,bus=virtio-serial0.0,nr=3,chardev=qga0,id=channel1,name=org.qemu.guest_agent.0 \



steps(){
#
echo


nc -U /tmp/qga.sock
{"execute":"guest-fstrim"}
}
