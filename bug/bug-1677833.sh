qemu-img create -f qcow2 /home/kvm_autotest_root/images/virtio_scsi_cdrom.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage2.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage3.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage4.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage5.qcow2 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage6.qcow2 30G


 /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/virtio_scsi_cdrom.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,serial=SYSTEM_DISK0,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
    \
    -blockdev node-name=file_stg,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg,drive=drive_stg,bootindex=1,write-cache=on,bus=pcie-root-port-3,addr=0x0,iothread=iothread1 \
    -blockdev node-name=file_stg2,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg2 \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,bootindex=2,write-cache=on,bus=pcie-root-port-4,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg3,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage3.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg3,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg3 \
    -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x1.0x5,bus=pcie.0,chassis=6 \
    -device virtio-blk-pci,id=stg3,drive=drive_stg3,bootindex=3,write-cache=on,bus=pcie-root-port-5,addr=0x0,iothread=iothread1 \
    -blockdev node-name=file_stg4,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage4.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg4,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg4 \
    -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x1.0x6,bus=pcie.0,chassis=7 \
    -device virtio-blk-pci,id=stg4,drive=drive_stg4,bootindex=4,write-cache=on,bus=pcie-root-port-6,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg5,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage5.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg5,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg5 \
    -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x1.0x7,bus=pcie.0,chassis=8 \
    -device virtio-blk-pci,id=stg5,drive=drive_stg5,bootindex=5,write-cache=on,bus=pcie-root-port-7,addr=0x0,iothread=iothread1 \
    \
    -device pcie-root-port,id=pcie-root-port-8,port=0x8,multifunction=on,bus=pcie.0,addr=0x3,chassis=9 \
    -device virtio-net-pci,mac=9a:1e:1a:be:c1:13,id=idoMHadp,netdev=idBNhvid,bus=pcie-root-port-8,addr=0x0  \
    -netdev tap,id=idBNhvid,vhost=on \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie-pci-bridge-0,addr=0x1 \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_may_2020_x64_dvd_5651846f.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device scsi-cd,id=cd1,drive=drive_cd1,bootindex=6,write-cache=on \
    -blockdev node-name=file_winutils,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_winutils,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_winutils \
    -device scsi-cd,id=winutils,drive=drive_winutils,bootindex=7,write-cache=on \
    -blockdev node-name=file_unattended,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64/autounattend.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_unattended,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_unattended \
    -device ide-cd,id=unattended,drive=drive_unattended,bootindex=8,write-cache=on,bus=ide.0,unit=0  \
    -vnc :5  \
    -qmp tcp:0:5955,server,nowait \
    -monitor stdio \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=d,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x4,chassis=10 \

steps(){
#remove data disks the installation succeed
  -blockdev node-name=file_stg,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg,drive=drive_stg,bootindex=1,write-cache=on,bus=pcie-root-port-3,addr=0x0,iothread=iothread1 \
    -blockdev node-name=file_stg2,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage2.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg2 \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-blk-pci,id=stg2,drive=drive_stg2,bootindex=2,write-cache=on,bus=pcie-root-port-4,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg3,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage3.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg3,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg3 \
    -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x1.0x5,bus=pcie.0,chassis=6 \
    -device virtio-blk-pci,id=stg3,drive=drive_stg3,bootindex=3,write-cache=on,bus=pcie-root-port-5,addr=0x0,iothread=iothread1 \
    -blockdev node-name=file_stg4,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage4.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg4,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg4 \
    -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x1.0x6,bus=pcie.0,chassis=7 \
    -device virtio-blk-pci,id=stg4,drive=drive_stg4,bootindex=4,write-cache=on,bus=pcie-root-port-6,addr=0x0,iothread=iothread0 \
    -blockdev node-name=file_stg5,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage5.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg5,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg5 \
    -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x1.0x7,bus=pcie.0,chassis=8 \
    -device virtio-blk-pci,id=stg5,drive=drive_stg5,bootindex=5,write-cache=on,bus=pcie-root-port-7,addr=0x0,iothread=iothread1 \

python ConfigTest.py --testcase=virtio_scsi_cdrom.with_installation.cdrom.extra_cdrom_ks.aio_native.multi_disk_install.q35 --iothread_scheme=roundrobin --nr_iothreads=2 --platform=x86_64 --guestname=Win2019 --driveformat=virtio_blk --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --customsparams="image_aio=threads\ncd_format=ide" --clone=no
unattended_install.cdrom.extra_cdrom_ks.multi_disk_install.aio_native.q35

}