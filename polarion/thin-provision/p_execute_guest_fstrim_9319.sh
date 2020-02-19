
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
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0 \
    -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-6,addr=0x0 \
    \
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \
    -blockdev driver=qcow2,node-name=disk_2,file=host_disk2 \
    -device scsi-hd,drive=disk_2,bus=scsi0.0,id=host_disk_2 \
    \
    -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/sdf,node-name=host_disk1,discard=unmap \
    -blockdev driver=raw,node-name=disk_1,file=host_disk1,cache.direct=on,cache.no-flush=off,discard=unmap \
    -device scsi-block,drive=disk_1,id=data-disk1,bus=scsi2.0 \
    \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 13312  \
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
-device virtio-serial-pci,disable-legacy=on,disable-modern=off,id=virtio-serial0 \
-chardev socket,path=/tmp/qga.sock,server,nowait,id=qga0 \
-device virtserialport,bus=virtio-serial0.0,nr=3,chardev=qga0,id=channel1,name=org.qemu.guest_agent.0 \



steps() {
#work for guest7,not work for guest8
-blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel78-64-virtio-scsi.qcow2,node-name=host_disk2 \
-blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \

    -drive file=/dev/sdf,if=none,id=drive-data-disk,format=raw,cache=none,aio=native,werror=stop,rerror=stop,discard=on \
-device scsi-block,drive=drive-data-disk,id=data-disk,bus=scsi2.0 \

    -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/sdf,node-name=host_disk1,discard=unmap \
    -blockdev driver=raw,node-name=disk_1,file=host_disk1,cache.direct=on,cache.no-flush=off,discard=unmap \
    -device scsi-block,drive=disk_1,id=data-disk1,bus=scsi2.0 \
    #host
    modprobe -r scsi_debug
    #unmap
    #modprobe scsi_debug add_host=1 sector_size=4096 lbpu=1 lbpws=1
    modprobe scsi_debug lbpu=1 lbpws=1
    #writesame_16
    #modprobe scsi_debug add_host=1 sector_size=4096 dev_size_mb=500  lbpu=0 lbpws=1 lbprz=0
    modprobe scsi_debug  lbpu=0 lbpws=1 lbprz=0


#guest
mkfs.ext4 /dev/sdb
mkdir -p /home/test;mount /dev/sdb /home/test
 dd if=/dev/zero of=/home/test/file

 rm /home/test/file
umount /home/test
#host
 cat /sys/bus/pseudo/drivers/scsi_debug/map


nc -U /tmp/qga.sock
{"execute":"guest-fstrim"}


}