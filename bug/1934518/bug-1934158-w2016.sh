#Bug 1934158 - Windows guest looses network connectivity when NIC was configured with static IP


/usr/libexec/qemu-kvm -name Win2016 \
-M pc-q35-rhel8.2.0,kernel-irqchip=split -m 8G \
-nodefaults \
-cpu Haswell-noTSX \
-smp 4,sockets=1,cores=4,threads=1 \
-device pcie-root-port,id=root.1,chassis=1,addr=0x2.0,multifunction=on \
-device pcie-root-port,id=root.2,chassis=2,addr=0x2.1 \
-device pcie-root-port,id=root.3,chassis=3,addr=0x2.2 \
-device pcie-root-port,id=root.4,chassis=4,addr=0x2.3 \
-device pcie-root-port,id=root.5,chassis=5,addr=0x2.4 \
-device pcie-root-port,id=root.6,chassis=6,addr=0x2.5 \
-device pcie-root-port,id=root.7,chassis=7,addr=0x2.6 \
-device pcie-root-port,id=root.8,chassis=8,addr=0x2.7 \
-device virtio-scsi-pci,id=scsi0,bus=root.3 \
-blockdev driver=file,filename=/home/kvm_autotest_root/images/win2016-64-virtio-scsi.qcow2,node-name=my_file \
-blockdev driver=qcow2,node-name=my,file=my_file \
-device scsi-hd,drive=my,id=virtio-blk0,bus=scsi0.0,bootindex=0 \
-blockdev driver=file,filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=my_file1 \
-blockdev driver=qcow2,node-name=mydata1,file=my_file1 \
-device virtio-blk-pci,drive=mydata1,id=data1,bus=root.2,bootindex=2 \
-blockdev driver=file,filename=/home/kvm_autotest_root/images/data2.qcow2,node-name=my_file2 \
-blockdev driver=qcow2,node-name=mydata2,file=my_file2 \
-device scsi-hd,drive=mydata2,id=data2,bus=scsi0.0,bootindex=3 \
\
-blockdev node-name=file_cd1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/iso/windows/virtio-win-1.9.15-0.el8.iso,cache.direct=on,cache.no-flush=off \
-blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
-device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0 \
-vnc :5 \
-vga qxl \
-monitor stdio \
-qmp tcp:0:5955,server,nowait \
-usb -device usb-tablet \
-boot menu=on \
-device virtio-net-pci,netdev=nic1,id=vnet0,mac=54:43:00:1a:11:33,bus=root.6 \
-netdev tap,id=nic1,vhost=on \


steps(){
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 1G
  qemu-img create -f qcow2 /home/kvm_autotest_root/images/data2.qcow2 2G

  python ConfigTest.py --testcase=x --guestname=Win2016 --driveformat=virtio_blk --machine=q35  --customsparams="cdrom_virtio = isos/windows/virtio-win-prewhql-0.1-195.iso"
  python ConfigTest.py --testcase=x --guestname=Win10 --imageformat=qcow2 --driveformat=virtio_scsi --platform=x86_64 --customsparam="machine_type = pc-q35-rhel8.2.0\ncdrom_virtio = isos/windows/virtio-win-prewhql-0.1-195.iso"

}
