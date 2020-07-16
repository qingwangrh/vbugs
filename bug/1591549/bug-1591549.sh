#Bug 1591549 - Detach disk with iothread and iotune configured when VM does not boot completely will cause qemu crash
#The point is the throttle+data plane+scsi,if remove <iotune> in xml or remove data plane only ,no issue
#only rhel7 found issue
#3.10.0-1152.el7.x86_64
#qemu-kvm-common-rhev-2.12.0-48.el7.x86_64
#libvirt-daemon-4.5.0-36.el7.x86_64
#
#Tested on following version, not hit this issue.
#
#4.18.0-214.el8.x86_64
#qemu-kvm-core-5.0.0-0.module+el8.3.0+6620+5d5e1420.x86_64
#libvirt-daemon-driver-qemu-6.0.0-25.module+el8.3.0+7176+57f10f42.x86_64
#
#
#4.18.0-193.10.1.el8_2.x86_64
#qemu-kvm-core-4.2.0-27.module+el8.2.1+7092+9d345e72.x86_64
#libvirt-libs-4.5.0-42.module+el8.2.0+6024+15a2423f.x86_64

#irrelevant disk source
#modprobe -r scsi_debug; modprobe scsi_debug lbpu=1 dev_size_mb=1024;lsblk -S|grep scsi_debug

qemu-img create -f raw /home/kvm_autotest_root/images/stg1.raw 1G
qemu-img create -f raw /home/kvm_autotest_root/images/stg2.raw 2G
qemu-img create -f raw /home/kvm_autotest_root/images/stg3.raw 3G

virsh destroy rhel77
virsh undefine rhel77
virsh define 1591549-rhel77.xml
virsh start rhel77
echo "gdb attach `pidof qemu-kvm` in new shell" 

sleep 10
#sleep 90 it is not related to boot,90 still hit this issue
echo "virsh detach-device rhel77 1591549-disk1.xml"
virsh detach-device rhel77 1591549-disk1.xml
#run gdb with new shell
#gdb attach `pidof qemu-kvm`
virsh list --all
