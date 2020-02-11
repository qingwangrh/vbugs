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
    -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0 \
    \
    -blockdev driver=host_device,cache.direct=off,cache.no-flush=on,filename=/dev/vgtest/lvtest,node-name=host_disk2 \
    -blockdev driver=raw,node-name=disk_2,file=host_disk2 \
    -device scsi-block,drive=disk_2,bus=scsi0.0,id=host_disk_2 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 8G  \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.8-Server-x86_64.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
    -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso \
    -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0 \
    -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=winutils,drive=drive_winutils,bootindex=4,bus=ide.2,unit=0\
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :8  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5958,server,nowait \


steps() {
-drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso \
-drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.8-Server-x86_64.iso \
#host
 Device     Boot   Start      End  Sectors Size Id Type
/dev/sdg1  *      16384  2113535  2097152   1G 83 Linux
/dev/sdg2       2113536 62914559 60801024  29G 8e Linux LVM

    iscsiadm -m discovery -t st -p 10.66.8.105
    iscsiadm --mode node --targetname iqn.2016-06.local.server:30  --portal 10.66.8.105:3260 --login
    systemctl restart iscsid iscsi

    pvcreate /dev/sdg1
    vgcreate vgtest /dev/sdg1
    lvcreate -n lvtest -L 28G vgtest

    # work on scsi-hd
    -blockdev driver=file,cache.direct=off,cache.no-flush=on,filename=/dev/vgtest/lvtest,node-name=host_disk2 \
    -blockdev driver=raw,node-name=disk_2,file=host_disk2 \
    -device scsi-hd,drive=disk_2,bus=scsi0.0,id=host_disk_2 \

    -drive file=/dev/vgtest/lvtest,if=none,id=disk1,format=raw,cache=unsafe,aio=native,werror=stop,rerror=stop \
    -device scsi-block,bus=scsi0.0,drive=disk1,id=scsi1,bootindex=3 \

    # work on scsi-block
    -blockdev driver=host_device,cache.direct=off,cache.no-flush=on,filename=/dev/vgtest/lvtest,node-name=host_disk2 \
    -blockdev driver=raw,node-name=disk_2,file=host_disk2 \
    -device scsi-block,drive=disk_2,bus=scsi0.0,id=host_disk_2 \

}
