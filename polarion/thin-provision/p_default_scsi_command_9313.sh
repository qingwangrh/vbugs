
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
    -blockdev driver=host_device,cache.direct=on,cache.no-flush=off,filename=/dev/sdh,node-name=host_disk1,read-only=on \
    -blockdev driver=raw,node-name=disk_1,file=host_disk1,cache.direct=on,cache.no-flush=off,read-only=on \
    -device scsi-block,drive=disk_1,id=data-disk1,bus=scsi2.0 \
    \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 13312  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
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
#host
    modprobe scsi-debug dev_size_mb=30 lbpu=1 lbpws10=1
     dd if=/dev/urandom of=/dev/sdh bs=4K
 cat /sys/bus/pseudo/drivers/scsi_debug/map
chmod ugo+rw /dev/sdh

#guest
sg_unmap -l0 -n61440 /dev/sdb

#host
cat /sys/bus/pseudo/drivers/scsi_debug/map
}