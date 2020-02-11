#Test point:scsi+
#-device discard=on works on fast train only
source common.sh

common_env "$@"
env_print


/usr/libexec/qemu-kvm \
-M pc \
-m 4G \
-smp 4 \
-rtc base=localtime,driftfix=slew \
-device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pci.0 \
-device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pci.0 \
-device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pci.0 \
-device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pci.0 \
\
-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel820-0.qcow2,node-name=drive_image1 \
-device virtio-scsi-pci,disable-legacy=on,disable-modern=off,id=scsi0,bus=pci.0 \
-device scsi-hd,bus=scsi0.0,drive=drive_image1,id=virtio-disk0,bootindex=1 \
-drive file=${img_dir}/${data1_img},format=qcow2,if=none,id=drive-virtio-disk0,discard=off \
-device virtio-blk-pci,bus=pcie.0-root-port-4,drive=drive-virtio-disk0,id=blk_data1,bootindex=2 \
-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${data2_img},node-name=data_image2 \
-device virtio-blk-pci,id=blk_data2,drive=data_image2,bus=pcie.0-root-port-5,addr=0x0,bootindex=3 \
-drive file=${img_dir}/${data3_img},format=qcow2,if=none,id=drive-virtio-disk3 \
-device virtio-blk-pci,bus=pcie.0-root-port-6,drive=drive-virtio-disk3,id=blk_data3,bootindex=4 \
\
-device piix3-usb-uhci,id=usb \
-device usb-tablet,id=tablet0 \
-vnc :5 \
-k en-us \
-qmp tcp:0:5955,server,nowait \
-boot menu=on \
-monitor stdio \
-device virtio-net-pci,mac=fa:f7:f8:5f:fa:5b,id=idn0VnaA,vectors=4,netdev=id8xJhp7,bus=pci.0 \
-netdev tap,id=id8xJhp7,vhost=on \


#-device intel-iommu,device-iotlb=on,intremap \
#-device virtio-blk-pci,iommu_platform=on,bus=pcie.0-root-port-3,drive=drive_image1,id=virtio-disk0,bootindex=1 \


#-drive file=${img_dir}/${os_img},if=none,format=qcow2,cache=none,werror=stop,rerror=stop,id=drive_image1,aio=native \
#-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${os_img},node-name=drive_image1 \
