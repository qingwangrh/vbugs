virsh destroy myagent

[ -f /home/kvm_autotest_root/images/stg0.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G
[ -f /home/kvm_autotest_root/images/stg1.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg1.qcow2 1.1G
[ -f /home/kvm_autotest_root/images/stg2.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg2.qcow2 1.2G
[ -f /home/kvm_autotest_root/images/stg3.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg3.qcow2 1.3G
[ -f /home/kvm_autotest_root/images/stg4.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg4.qcow2 1.4G
[ -f /home/kvm_autotest_root/images/stg5.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg5.qcow2 1.5G
[ -f /home/kvm_autotest_root/images/stg6.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg6.qcow2 1.6G
[ -f /home/kvm_autotest_root/images/stg7.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg7.qcow2 1.7G
[ -f /home/kvm_autotest_root/images/stg8.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg8.qcow2 1.8G
[ -f /home/kvm_autotest_root/images/stg9.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg9.qcow2 1.9G
[ -f /home/kvm_autotest_root/images/stg10.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg10.qcow2 2G
[ -f /home/kvm_autotest_root/images/stg11.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg11.qcow2 2.1G

qemu-img create -f qcow2 -b /home/kvm_autotest_root/images/stg1.qcow2 /home/kvm_autotest_root/images/stg1-1.qcow2 1G


virsh destroy myagent
virsh undefine myagent
virsh define agent-pc3.xml
virsh start myagent

sleep 30
#host
date;echo `date`>t;a=1;while true;do let a=a+1;echo "a=$a";virsh detach-device myagent diskb.xml; [[ $? == 0 ]] || exit;sleep 1; virsh attach-device myagent diskb.xml;[[ $? == 0 ]] || exit;sleep 1;done;echo `date`>>t;date
#guest
#while true;do sg_luns /dev/sda;done

#run.bat
#:redo
#sg_luns c:
#timeout /t 1
#goto redo