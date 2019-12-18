/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-3,addr=0x0 \
    -drive id=drive_image1,if=none,snapshot=off,aio=native,cache=none,format=qcow2,file=/home/windbg/win2019-windbg.qcow2 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=1,serial=SYSTEM_DISK0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:53:8b:48:22:68,id=idj4vsZc,netdev=idTJmzbG,bus=pcie.0-root-port-4,addr=0x0  \
    -netdev tap,id=idTJmzbG,vhost=on \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,sockets=2  \
    -drive id=drive_cd1,if=none,snapshot=off,aio=native,cache=none,media=cdrom,file=/home/windbg/windowsdk.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
    -drive id=drive_winutils,if=none,snapshot=off,aio=native,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.1,unit=0 \
    -drive id=drive_virtio_win,if=none,snapshot=off,aio=native,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-172.iso \
    -device ide-cd,id=virtio_win,drive=drive_virtio_win,bus=ide.2,unit=0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :8  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=d,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5958,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \
