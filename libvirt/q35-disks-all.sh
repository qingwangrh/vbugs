qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 3G

qemu-img create --object secret,id=test1_encrypt0,data=redhat -f luks -o key-secret=test1_encrypt0 /home/kvm_autotest_root/images/stg5.luks 2G

qemu-img create -f raw /home/kvm_autotest_root/images/stg2.raw 2G
qemu-img create -f raw /home/kvm_autotest_root/images/stg4.raw 4G
qemu-img create -f raw /home/kvm_autotest_root/images/stg5.raw 5G
qemu-img create -f raw /home/kvm_autotest_root/images/fda.img 1G
#modprobe -r scsi_debug; modprobe scsi_debug  lbpu=1 lbpws=1 lbprz=0
modprobe scsi_debug dev_size_mb=100 num_tgts=1 vpd_use_hostno=0 add_host=2 delay=1 max_luns=2 no_lun_0=1


mapper=`multipath -l|grep scsi_debug|cut -f 1 -d " "`
echo "multipath -f /dev/mapper/$mapper;modprobe -r scsi_debug"
dev=`lsscsi |grep scsi|awk '{ print $6 }'`;echo $dev

virsh secret-define volume-secret.xml
virsh secret-list