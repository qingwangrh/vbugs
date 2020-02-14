#test point: slow train not support
#fast train: it may support

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -device pcie-root-port,id=pcie.0-root-port-9,slot=9,chassis=9,addr=0x9,bus=pcie.0 \
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0 \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-6,addr=0x0 \
    -object iothread,id=iothread2 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \
    -blockdev driver=qcow2,node-name=disk_2,file=host_disk2 \
    -device scsi-hd,drive=disk_2,bus=scsi0.0,id=host_disk_2 \
    \
    -blockdev node-name=file_stg1,driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/sdb,discard=unmap \
    -blockdev node-name=drive_stg1,driver=raw,cache.direct=on,cache.no-flush=off,file=file_stg1,discard=unmap \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,write-cache=on,bus=pcie.0-root-port-9,addr=0x0,iothread=iothread2 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 13312  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
    -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso \
    -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0 \
    -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.2,unit=0\
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \



steps() {

-drive file=/dev/sdb,if=none,id=drive-data-disk,format=raw,cache=none,aio=native,werror=stop,rerror=stop,discard=on \
-device virtio-blk-pci,bus=pci.0,addr=0x8,drive=drive-data-disk,id=data-disk \
#(make sure install sg3_utils in guest)
#host

   lsblk
sdf                                8:80   0     2G  0 disk

modprobe -r scsi_debug;modprobe scsi_debug lbpu=1 lbpws=1 lbprz=0
cat /sys/block/sdh/device/scsi_disk/19\:0\:0\:0/provisioning_mode
   unmap

    #guest
 dd if=/dev/zero of=/dev/vda bs=1M

parted /dev/vda mklabel msdos
parted /dev/vda mkpart primary ext2 2048s 100%
mkfs.ext4 /dev/vda1
mkdir -p test
mount /dev/vda1 test
fstrim ./test

#fstrim: ./test: the discard operation is not supported
#host

cat /sys/bus/pseudo/drivers/scsi_debug/map

}