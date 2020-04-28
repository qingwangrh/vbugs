


/usr/libexec/qemu-kvm \
-M q35,kernel-irqchip=split \
-cpu host \
-enable-kvm \
-m 2G \
-smp 4 \
-rtc base=localtime,driftfix=slew \
-device intel-iommu,device-iotlb=on,intremap \
-device virtio-scsi-pci,id=scsi0,bus=pcie.0 \
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
-device virtio-scsi-pci,id=scsi1,bus=pcie.0 \
-drive file=/home/kvm_autotest_root/images/data1.qcow2,if=none,format=qcow2,cache=none,id=data1 \
-device scsi-hd,bus=scsi1.0,drive=data1,id=virtio-data1 \
-drive file=/home/kvm_autotest_root/images/data2.qcow2,if=none,format=qcow2,cache=none,id=data2 \
-device scsi-hd,bus=scsi1.0,drive=data2,id=virtio-data2 \
-drive file=/home/kvm_autotest_root/images/data3.qcow2,if=none,format=qcow2,cache=none,id=data3 \
-device scsi-hd,bus=scsi1.0,drive=data3,id=virtio-data3 \
-drive file=/home/kvm_autotest_root/images/data4.qcow2,if=none,format=qcow2,cache=none,id=data4 \
-device scsi-hd,bus=scsi1.0,drive=data4,id=virtio-data4 \
-drive file=/home/kvm_autotest_root/images/data5.qcow2,if=none,format=qcow2,cache=none,id=data5 \
-device scsi-hd,bus=scsi1.0,drive=data5,id=virtio-data5 \
-drive file=/home/kvm_autotest_root/images/data6.qcow2,if=none,format=qcow2,cache=none,id=data6 \
-device scsi-hd,bus=scsi1.0,drive=data6,id=virtio-data6 \
-drive file=/home/kvm_autotest_root/images/data7.qcow2,if=none,format=qcow2,cache=none,id=data7 \
-device scsi-hd,bus=scsi1.0,drive=data7,id=virtio-data7 \
-drive file=/home/kvm_autotest_root/images/data8.qcow2,if=none,format=qcow2,cache=none,id=data8 \
-device scsi-hd,bus=scsi1.0,drive=data8,id=virtio-data8 \
-drive file=/home/kvm_autotest_root/images/data9.qcow2,if=none,format=qcow2,cache=none,id=data9 \
-device scsi-hd,bus=scsi1.0,drive=data9,id=virtio-data9 \
-drive file=/home/kvm_autotest_root/images/data10.qcow2,if=none,format=qcow2,cache=none,id=data10 \
-device scsi-hd,bus=scsi1.0,drive=data10,id=virtio-data10 \
-drive file=/home/kvm_autotest_root/images/data11.qcow2,if=none,format=qcow2,cache=none,id=data11 \
-device scsi-hd,bus=scsi1.0,drive=data11,id=virtio-data11 \
-drive file=/home/kvm_autotest_root/images/data12.qcow2,if=none,format=qcow2,cache=none,id=data12 \
-device scsi-hd,bus=scsi1.0,drive=data12,id=virtio-data12 \



steps(){
echo
wloop 1 64 "qemu-img create -f qcow2 /home/kvm_autotest_root/images/data@@.qcow2 256M"

#

{"execute":"qmp_capabilities"}

{"execute": "device_del", "arguments": {"id": "virtio-data1"} , "id": "XVosfh01"}
{"execute": "device_del", "arguments": {"id": "virtio-data2"} , "id": "XVosfh02"}
{"execute": "device_del", "arguments": {"id": "virtio-data3"} , "id": "XVosfh03"}
{"execute": "device_del", "arguments": {"id": "virtio-data4"} , "id": "XVosfh04"}

{"execute": "device_del", "arguments": {"id": "virtio-data5"} , "id": "XVosfh05"}
{"execute": "device_del", "arguments": {"id": "virtio-data6"} , "id": "XVosfh06"}
{"execute": "device_del", "arguments": {"id": "virtio-data7"} , "id": "XVosfh07"}
{"execute": "device_del", "arguments": {"id": "virtio-data8"} , "id": "XVosfh08"}

{"execute": "device_del", "arguments": {"id": "virtio-data9"} , "id": "XVosfh09"}
{"execute": "device_del", "arguments": {"id": "virtio-data10"} , "id": "XVosfh10"}
{"execute": "device_del", "arguments": {"id": "virtio-data11"} , "id": "XVosfh11"}
{"execute": "device_del", "arguments": {"id": "virtio-data12"} , "id": "XVosfh12"}


}

