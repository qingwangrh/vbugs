#/home/kvm_autotest_root/images/win10-32.qcow2

qemu-img create -f qcow2 /home/images/data1.qcow2 5.1G
qemu-img create -f qcow2 /home/images/data2.qcow2 5.2G
qemu-img create -f qcow2 /home/images/data3.qcow2 5.3G
qemu-img create -f qcow2 /home/images/data4.qcow2 5.4G

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm3' \
    -machine q35  \
    -nodefaults \
    -vga std  \
    -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
    -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 \
    -device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
    -device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 \
    -device pcie-root-port,port=0x14,chassis=5,id=pci.5,bus=pcie.0,addr=0x2.0x4 \
    -device pcie-root-port,port=0x15,chassis=6,id=pci.6,bus=pcie.0,addr=0x2.0x5 \
    -device pcie-root-port,port=0x16,chassis=7,id=pci.7,bus=pcie.0,addr=0x2.0x6 \
    -device pcie-root-port,port=0x17,chassis=8,id=pci.8,bus=pcie.0,addr=0x2.0x7 \
    -blockdev node-name=file_os_stg1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/win10-32.qcow2,aio=threads \
    -blockdev node-name=drive_os_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_os_stg1 \
    -device virtio-blk-pci,id=os_stg1,drive=drive_os_stg1,addr=0x0,serial=luckyluckylucky,bus=pci.2,bootindex=1 \
    -device virtio-net-pci,mac=9a:36:83:b6:3d:05,id=idJVpmsF,netdev=id23ZUK6,bus=pci.3  \
    -netdev tap,id=id23ZUK6,vhost=on \
    -m 14336  \
    -smp 2,maxcpus=4 \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
    -device piix3-usb-uhci,id=usb -device usb-tablet,id=input0 \
    -vnc :7  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -qmp tcp:0:5957,server,nowait \
    -monitor stdio \
    -device virtio-scsi-pci,id=scsi0,bus=pci.4 \
    -blockdev node-name=file_stg1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data1.qcow2 \
    -blockdev node-name=drive_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg1 \
    -device virtio-blk-pci,id=data1,drive=drive_stg1,addr=0x0,serial=lucky,bus=pci.5,addr=0x0    \
    \
    -blockdev node-name=file_stg2,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data2.qcow2 \
    -blockdev node-name=drive_stg2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg2 \
    -device scsi-hd,id=scsi_data2,drive=drive_stg2,bus=scsi0.0 \
    \
    -drive file=/home/images/data3.qcow2,format=qcow2,if=none,id=drive-virtio-disk0 \
    -device virtio-blk-pci,bus=pci.6,drive=drive-virtio-disk0,id=blk_data3 \
    -drive file=/home/images/data4.qcow2,format=qcow2,if=none,id=drive-virtio-disk1 \
    -device scsi-hd,id=scsi_data4,drive=drive-virtio-disk1,bus=scsi0.0 \


#need add discard=unmap on both blockdev nodes
#just work on drive+scsi-hd,blockdev+blk
steps(){

-blockdev node-name=file_os_stg1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/win10-32.qcow2,aio=threads \
-blockdev node-name=file_os_stg1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/rhel820-64-virtio-scsi.qcow2,aio=threads \

    -blockdev node-name=file_stg1,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data1.qcow2,aio=threads,discard=unmap \
    -blockdev node-name=drive_stg1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg1,discard=unmap \
    -device virtio-blk-pci,id=data1,drive=drive_stg1,addr=0x0,serial=lucky,bus=pci.5,addr=0x0    \
    \
    -blockdev node-name=file_stg2,driver=file,cache.direct=on,cache.no-flush=off,filename=/home/images/data2.qcow2,aio=threads,discard=unmap \
    -blockdev node-name=drive_stg2,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg2,discard=unmap \
    -device scsi-hd,id=scsi_data2,drive=drive_stg2,bus=scsi0.0 \
    \
    -drive file=/home/images/data3.qcow2,format=qcow2,if=none,id=drive-virtio-disk0,discard=on \
    -device virtio-blk-pci,bus=pci.6,drive=drive-virtio-disk0,id=blk_data3 \
    -drive file=/home/images/data4.qcow2,format=qcow2,if=none,id=drive-virtio-disk1,discard=on \
    -device scsi-hd,id=scsi_data4,drive=drive-virtio-disk1,bus=scsi0.0 \


#host
qemu-img create -f qcow2 data2.qcow2 5G
du -h data{1,2,3,4}.qcow2

#guest
defrag.exe f: /l /u /v

}