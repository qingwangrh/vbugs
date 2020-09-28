
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
    -blockdev driver=file,cache.direct=on,cache.no-flush=off,filename=/home/kvm_autotest_root/images/test.img,node-name=data_disk,discard=unmap \
    -blockdev driver=raw,node-name=disk1,file=data_disk,cache.direct=on,cache.no-flush=off,discard=unmap \
    -device scsi-hd,drive=disk1,bus=scsi2.0,id=data_disk,write-cache=on,logical_block_size=4096,physical_block_size=4096 \
    \
     -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/sdd,node-name=host_disk1,discard=unmap \
    -blockdev driver=raw,node-name=disk_1,file=host_disk1,cache.direct=on,cache.no-flush=off,discard=unmap \
    -device scsi-hd,drive=disk_1,id=data-disk1,bus=scsi2.0,write-cache=on,logical_block_size=4096,physical_block_size=4096 \
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

-drive file=/home/test.img,if=none,id=drive-data-disk,format=raw,cache=none,aio=native,werror=stop,rerror=stop,discard=on \
-device scsi-hd,drive=drive-data-disk,id=data-disk,logical_block_size=4096,bus=scsi1.0
#(make sure install sg3_utils in guest)
#host
    #create image on host xfs
    qemu-img create -f raw /home/kvm_autotest_root/images/test.img 1G
    modprobe -r scsi_debug
    modprobe scsi_debug lbprz=1 lbpu=1 dev_size_mb=1024
    modprobe scsi_debug lbprz=0 lbpu=1 dev_size_mb=1024

     cat /sys/bus/pseudo/drivers/scsi_debug/map

#guest
    yes | head -n2048 > buf
 sg_write_same --in buf --num=32 --lba=80 /dev/sdb
 sg_write_same --in /dev/zero --num=96 --lba=0 /dev/sdb
 sg_write_same -U --in /dev/zero --num=16 --lba=0 /dev/sdb
 time sg_write_same --in buf --num=65536 --lba=131074 /dev/sdb
 time sg_write_same --in /dev/zero --num=65534 --lba=196608 /dev/sdb
 sg_write_same --in /dev/zero --num=0 --lba=128 /dev/sdb

 sha1sum /dev/sdb
#host
 /home/kvm_autotest_root/images/test.img
cat /sys/bus/pseudo/drivers/scsi_debug/map

}