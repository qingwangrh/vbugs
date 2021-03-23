/usr/libexec/qemu-kvm \ 
-M q35,kernel-irqchip=split \
-cpu host \ 
-enable-kvm \ 
-m 2G \ 
-smp 4 \ 
-nodefconfig \ 
-rtc base=localtime,driftfix=slew \ 
-device intel-iommu,device-iotlb=on,intremap \ 
-device virtio-scsi-pci,disable-legacy=on,disable-modern=off,iommu_platform=on,ats=on,id=scsi0,bus=pcie.0 \ 
-drive file=rhel76-64-virtio-scsi.qcow2,if=none,format=qcow2,cache=none,werror=stop,rerror=stop,id=drive-virtio-disk0,aio=native \ 
-device scsi-hd,bus=scsi0.0,drive=drive-virtio-disk0,id=virtio-disk0 \ 
-device piix3-usb-uhci,id=usb \ 
-device usb-tablet,id=tablet0 \ 
-vnc :0 \ 
-k en-us \ 
-vga std \ 
-qmp tcp:0:4444,server,nowait \ 
-boot menu=on \ 
-monitor stdio \ 
-device virtio-net-pci,mac=fa:f7:f8:5f:fa:5b,id=idn0VnaA,vectors=4,netdev=id8xJhp7,bus=pcie.0,addr=06 \ 
-netdev tap,id=id8xJhp7,vhost=on \

