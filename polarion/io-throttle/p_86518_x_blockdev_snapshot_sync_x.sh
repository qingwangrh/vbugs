qemu-img create -f raw /home/kvm_autotest_root/images/stg1.raw 11G

pc(){

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 4096  \
    -smp 16,maxcpus=16,cores=8,threads=1,dies=1,sockets=2  \
    -cpu 'EPYC-Rome',+kvm_pv_unhalt \
    \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,x-iops-total=50,x-iops-total-max=60,x-iops-total-max-length=10,id=group1 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pci.0,addr=0x4 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device scsi-hd,id=image1,drive=drive_image1,write-cache=on \
    -blockdev node-name=file_stg1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg1,driver=qcow2,file=file_stg1,read-only=off,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=qcow2_stg1 \
    -device scsi-hd,id=stg1,drive=drive_stg1,write-cache=on,serial=TARGET_DISK1 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=idMNkWPI,netdev=idqjZ2Dz,bus=pci.0,addr=0x5  \
    -netdev tap,id=idqjZ2Dz,vhost=on  \
\
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}

q35(){

  /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 4G  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,id=group1,x-iops-total=50 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0 \
    \
    -blockdev node-name=file_stg1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg1.raw,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=raw_stg1,driver=raw,file=file_stg1,read-only=off,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=raw_stg1 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bootindex=1,write-cache=on,serial=TARGET_DISK1,bus=pcie-root-port-3,addr=0x0 \
    \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=idjlChg9,netdev=idqaVU9W,bus=pcie-root-port-4,addr=0x0  \
    -netdev tap,id=idqaVU9W,vhost=on \
    -vnc :5  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}

q35_win(){

  /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 4g  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object throttle-group,x-iops-total=50,id=group1 \
    -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0 \
    -blockdev node-name=file_stg1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/images/stg1.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=qcow2_stg1,driver=qcow2,file=file_stg1,read-only=off,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg1,driver=throttle,throttle-group=group1,file=qcow2_stg1 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-blk-pci,id=stg1,drive=drive_stg1,bootindex=1,write-cache=on,serial=TARGET_DISK1,bus=pcie-root-port-3,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x1.0x4,bus=pcie.0,chassis=5 \
    -device virtio-net-pci,mac=9a:30:62:be:63:16,id=idUnxD3q,netdev=idm6t6K2,bus=pcie-root-port-4,addr=0x0  \
    -netdev tap,id=idm6t6K2,vhost=on \
    -blockdev node-name=file_cd1,driver=file,auto-read-only=on,discard=unmap,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,write-cache=on,bus=ide.0,unit=0  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=6 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}

q35_win

step(){

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 11G
-object throttle-group,id=group1,x-iops-total=50 \
    -object throttle-group,x-iops-total=50,x-iops-total-max=60,x-iops-total-max-length=10,id=group1



 {"execute": "qmp_capabilities"}
 {"execute": "blockdev-create", "arguments": {"options": {"driver": "file", "filename": "/home/kvm_autotest_root/images/sn1.qcow2", "size": 11811160064}, "job-id": "file_sn1"}, "id": "UykdzSZB"}
 {"execute": "query-jobs", "id": "MlVw8BSf"}
 {"execute": "job-dismiss", "arguments": {"id": "file_sn1"}, "id": "D7CrB4xG"}
 {"execute": "blockdev-add", "arguments": {"node-name": "file_sn1", "driver": "file", "filename": "/home/kvm_autotest_root/images/sn1.qcow2", "aio": "threads", "auto-read-only": true, "discard": "unmap"}, "id": "KSUUeDYE"}

 {"execute": "blockdev-create", "arguments": {"options": {"driver": "qcow2", "file": "file_sn1", "size": 11811160064}, "job-id": "drive_sn1"}, "id": "IWREBT9F"}
 {"execute": "query-jobs", "id": "nwJnZqzY"}

 {"execute": "job-dismiss", "arguments": {"id": "drive_sn1"}, "id": "iR5RguRp"}
 {"execute": "query-jobs", "id": "axranwMC"}
 {"execute": "blockdev-add", "arguments": {"node-name": "drive_sn1", "driver": "qcow2", "file": "file_sn1", "read-only": false}, "id": "iGUQD38a"}

 {"execute": "blockdev-snapshot", "arguments": {"node": "drive_stg1", "overlay": "drive_sn1"}, "id": "7UAdhqLR"}





}