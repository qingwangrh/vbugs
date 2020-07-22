#point only works on intel cpu lscpu |grep endo
qemu-img create -f qcow2 /home/kvm_autotest_root/images/storage_iommu.qcow2 30G

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35,kernel-irqchip=split \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,num_queues=12,bus=pcie-root-port-2,addr=0x0,iommu_platform=on,ats=on \
    -blockdev node-name=file_stg_iommu,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/storage_iommu.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_stg_iommu,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg_iommu \
    -device scsi-hd,id=stg_iommu,drive=drive_stg_iommu,write-cache=on \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:55:b4:ca:a3:fa,id=id2FUlK8,netdev=idDJ5U7n,bus=pcie-root-port-3,addr=0x0,iommu_platform=on,ats=on  \
    -netdev tap,id=idDJ5U7n,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_may_2020_x64_dvd_5651846f.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=ide.0,unit=0 \
    -blockdev node-name=file_winutils,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_winutils,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_winutils \
    -device ide-cd,id=winutils,drive=drive_winutils,write-cache=on,bus=ide.1,unit=0 \
    -blockdev node-name=file_unattended,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64/autounattend.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_unattended,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_unattended \
    -device ide-cd,id=unattended,drive=drive_unattended,write-cache=on,bus=ide.2,unit=0  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \
    \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
 -device intel-iommu,device-iotlb=on,intremap \
