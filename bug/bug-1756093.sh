#unplug scsi disks number great than 8


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
-drive file=/home/kvm_autotest_root/images/stg1.qcow2,if=none,format=qcow2,cache=none,id=data1 \
-device scsi-hd,bus=scsi1.0,drive=data1,id=virtio-data1 \
-drive file=/home/kvm_autotest_root/images/stg2.qcow2,if=none,format=qcow2,cache=none,id=data2 \
-device scsi-hd,bus=scsi1.0,drive=data2,id=virtio-data2 \
-drive file=/home/kvm_autotest_root/images/stg3.qcow2,if=none,format=qcow2,cache=none,id=data3 \
-device scsi-hd,bus=scsi1.0,drive=data3,id=virtio-data3 \
-drive file=/home/kvm_autotest_root/images/stg4.qcow2,if=none,format=qcow2,cache=none,id=data4 \
-device scsi-hd,bus=scsi1.0,drive=data4,id=virtio-data4 \
-drive file=/home/kvm_autotest_root/images/stg5.qcow2,if=none,format=qcow2,cache=none,id=data5 \
-device scsi-hd,bus=scsi1.0,drive=data5,id=virtio-data5 \
-drive file=/home/kvm_autotest_root/images/stg6.qcow2,if=none,format=qcow2,cache=none,id=data6 \
-device scsi-hd,bus=scsi1.0,drive=data6,id=virtio-data6 \
-drive file=/home/kvm_autotest_root/images/stg7.qcow2,if=none,format=qcow2,cache=none,id=data7 \
-device scsi-hd,bus=scsi1.0,drive=data7,id=virtio-data7 \
-drive file=/home/kvm_autotest_root/images/stg8.qcow2,if=none,format=qcow2,cache=none,id=data8 \
-device scsi-hd,bus=scsi1.0,drive=data8,id=virtio-data8 \
-drive file=/home/kvm_autotest_root/images/stg9.qcow2,if=none,format=qcow2,cache=none,id=data9 \
-device scsi-hd,bus=scsi1.0,drive=data9,id=virtio-data9 \
-drive file=/home/kvm_autotest_root/images/stg10.qcow2,if=none,format=qcow2,cache=none,id=data10 \
-device scsi-hd,bus=scsi1.0,drive=data10,id=virtio-data10 \
-drive file=/home/kvm_autotest_root/images/stg11.qcow2,if=none,format=qcow2,cache=none,id=data11 \
-device scsi-hd,bus=scsi1.0,drive=data11,id=virtio-data11 \
-drive file=/home/kvm_autotest_root/images/stg12.qcow2,if=none,format=qcow2,cache=none,id=data12 \
-device scsi-hd,bus=scsi1.0,drive=data12,id=virtio-data12 \



steps(){
echo
wloop 1 64 "qemu-img create -f qcow2 /home/kvm_autotest_root/images/data@@.qcow2 256M"

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 2G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 4G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg5.qcow2 5G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg6.qcow2 6G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 7G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg8.qcow2 8G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg9.qcow2 9G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg10.qcow2 10G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg11.qcow2 11G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg12.qcow2 12G

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


#
{'execute':'device_del','arguments':{'id':'scsi1'}}

#need to do drive_add before
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk1","id":"data_disk1","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk2","id":"data_disk2","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk3","id":"data_disk3","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk4","id":"data_disk4","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk5","id":"data_disk5","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk6","id":"data_disk6","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk7","id":"data_disk7","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk8","id":"data_disk8","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk9","id":"data_disk9","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk10","id":"data_disk10","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk11","id":"data_disk11","bus":"scsi1.0"}}
{"execute":"device_add","arguments":{"driver":"scsi-hd","drive":"disk12","id":"data_disk12","bus":"scsi1.0"}}

#BUG:if we do not delete  virtio_scsi_pci1, only 8 disk can be deleted.
# but other disk can not access, if we execute fdisk
fdisk: cannot open /dev/sdi: Input/output error; the disk will disappear
reboot guest and disks will disappear, it looks like the disks indeed delete,
but not refresh on guest?
please refer to 1516105

Bug 1843324 - Guest failed to sync block info after hot unplugged multiple disks(greater than 8 disks)
Reproduce via automation CML:

python3 ConfigTest.py --guestname=RHEL.8.3.0 --driveformat=virtio_scsi --nicmodel=virtio_net --testcase=multi_disk_random_hotplug.parallel.single_type --clone=no  --nrepeat=50


}

