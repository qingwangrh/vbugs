/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 14336  \
    -smp 12,maxcpus=12,cores=6,threads=1,sockets=2  \
    -cpu 'Opteron_G5',hv_stimer,hv_synic,hv_vpindex,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv_frequencies,hv_runtime,+kvm_pv_unhalt \
    -device pvpanic,ioport=0x505,id=id9rD9rs \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2 \
    -device scsi-hd,id=image1,drive=drive_image1 \
    -device virtio-net-pci,mac=9a:23:af:0e:cf:5e,id=id8c9mXf,netdev=idKuMY58,bus=pci.0,addr=0x5  \
    -netdev tap,id=idKuMY58,vhost=on  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm -monitor stdio \
    -vnc :6 \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp6.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5956,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serial6.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \


steps(){

dd if=/dev/urandom of=/tmp/new bs=10M count=1 && mkisofs -o /tmp/new.iso /tmp/new

drive_add auto id=drive_cd2,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/tmp/new.iso

 {"execute": "qmp_capabilities"}
{"execute": "device_add", "arguments": {"driver": "scsi-cd", "id": "cd2", "drive": "drive_cd2", "bus": "virtio_scsi_pci0.0"}, "id": "lXpMsDCD"}

#guest
wmic logicaldisk where (Description='CD-ROM Disc') get DeviceID
}

