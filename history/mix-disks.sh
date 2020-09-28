


/usr/libexec/qemu-kvm \
-M q35,kernel-irqchip=split \
-cpu host \
-enable-kvm \
-m 4G \
-smp 4 \
-rtc base=localtime,driftfix=slew \
-device intel-iommu,device-iotlb=on,intremap \
-device pcie-root-port,port=0x10,chassis=1,id=pcie_port_0,bus=pcie.0,multifunction=on,addr=0x2 \
-device pcie-root-port,port=0x11,chassis=2,id=pcie_port_1,bus=pcie.0,addr=0x2.0x1 \
-device pcie-root-port,port=0x12,chassis=3,id=pcie_port_2,bus=pcie.0,addr=0x2.0x2 \
-device pcie-root-port,port=0x13,chassis=4,id=pcie_port_3,bus=pcie.0,addr=0x2.0x3 \
-device pcie-root-port,port=0x14,chassis=5,id=pcie_port_4,bus=pcie.0,addr=0x2.0x4 \
-device pcie-root-port,port=0x15,chassis=6,id=pcie_port_5,bus=pcie.0,addr=0x2.0x5 \
-device pcie-root-port,port=0x16,chassis=7,id=pcie_port_6,bus=pcie.0,addr=0x2.0x6 \
-device pcie-root-port,port=0x17,chassis=8,id=pcie_port_7,bus=pcie.0,addr=0x2.0x7 \
-device virtio-scsi-pci,id=scsi0,bus=pcie_port_5,multifunction=on \
-device virtio-scsi-pci,id=scsi1,bus=pcie_port_6,multifunction=on \
-drive file=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,if=none,format=qcow2,cache=none,werror=stop,rerror=stop,id=drive-virtio-disk0,aio=native \
-device scsi-hd,bus=scsi0.0,drive=drive-virtio-disk0,id=virtio-disk0 \
-device piix3-usb-uhci,id=usb \
-device usb-tablet,id=tablet0 \
-vnc :5 \
-k en-us \
-vga std \
-qmp tcp:0:5955,server,nowait \
-boot menu=on \
-monitor stdio \
-device virtio-net-pci,mac=fa:f7:f8:5f:fa:5b,id=idn0VnaA,vectors=4,netdev=id8xJhp7,bus=pcie.0,addr=06 \
-netdev tap,id=id8xJhp7,vhost=on \
\
-drive file=/home/kvm_autotest_root/images/stg1.qcow2,if=none,format=qcow2,cache=none,id=data1 \
-drive file=/home/kvm_autotest_root/images/stg2.qcow2,if=none,format=qcow2,cache=none,id=data2 \
-device scsi-hd,bus=scsi1.0,drive=data1,id=disk1 \
-device virtio-blk-pci,id=disk2,drive=data2,bus=pcie_port_1 \
\
-blockdev node-name=file_stg3,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg3.qcow2,cache.direct=on,cache.no-flush=off \
-blockdev node-name=data3,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg3 \
-blockdev node-name=file_stg4,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/stg4.qcow2,cache.direct=on,cache.no-flush=off \
-blockdev node-name=data4,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_stg4 \
-device scsi-hd,bus=scsi1.0,drive=data3,id=disk3 \
-device virtio-blk-pci,id=disk4,drive=data4,bus=pcie_port_2 \




steps(){
echo

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
#

{"execute":"qmp_capabilities"}

{"execute": "query-block"}


}

