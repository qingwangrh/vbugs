#!/usr/bin/env bash

trace-cmd record -e kvm \
  /usr/libexec/qemu-kvm \
   \
    -name 'avocado-vt-vm1' \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2  \
    \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pci.0,addr=0x4 \
    -drive id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage0.raw \
    -device virtio-blk-pci,id=stg0,drive=drive_stg0,bootindex=1,bus=pci.0,addr=0x5 \
    -drive id=drive_stg1,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage1.raw \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bootindex=2,bus=pci.0,addr=0x6 \
    -device virtio-net-pci,mac=9a:f4:67:57:41:48,id=idynkpcz,netdev=idZri0rC,bus=pci.0,addr=0x7  \
    -netdev tap,id=idZri0rC,vhost=on \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,sockets=2  \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=3,bus=ide.0,unit=0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:5956,server,nowait \
        -monitor stdio \


steps(){

  yum install trace-cmd -y
  qemu-img create -f raw /home/kvm_autotest_root/images/storage0.raw 10G
  qemu-img create -f raw /home/kvm_autotest_root/images/storage1.raw 11G

  D:\iozone\iozone.exe -a -I -f E:\testfile
  D:\iozone\iozone.exe -a -I -f F:\testfile
  D:\iozone\iozone.exe -a -I -f C:\testfile

   python3 ConfigTest.py --nrepeat=1 --platform=x86_64 --guestname=Win2016 --imageformat=raw --testcase=iozone_windows.long_time_stress.i440fx --driveformat=virtio_blk --machine=i440fx --customsparam="qemu_force_use_drive_expression = yes\ncdrom_virtio = isos/windows/virtio-win-prewhql-0.1-185.iso"

}