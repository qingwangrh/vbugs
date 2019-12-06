
    #-cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,chassis=2,bus=pcie.0,addr=0x2,multifunction=on \
    -device pcie-root-port,id=pcie.0-root-port-3,chassis=3,bus=pcie.0,addr=0x2.0x1 \
    -device pcie-root-port,id=pcie.0-root-port-4,chassis=4,bus=pcie.0,addr=0x2.0x2 \
    -device pcie-root-port,id=pcie.0-root-port-5,chassis=5,bus=pcie.0,addr=0x2.0x3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-5,multifunction=on \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/images/rhel810.qcow2 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie.0-root-port-3,addr=0x0 \
    -drive id=data_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/images/data1.qcow2 \
    -device virtio-blk-pci,id=data_image1,drive=data_image1,bus=pcie.0-root-port-4,addr=0x0 \
    -drive id=data_image2,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/images/data2.qcow2 \
    -device scsi-hd,id=data_image2,drive=data_image2,bus=virtio_scsi_pci0.0 \
    -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:61,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-8,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 16000  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-8.1.0-20191015.0-x86_64-dvd1.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :0  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:4445,server,nowait \
    -chardev file,path=/home/images/serial-l.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \




#-device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0,addr=0x4 \
