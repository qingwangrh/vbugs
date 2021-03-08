#!/usr/bin/env bash

qemu-kvm-block-curl-2.12.0-99.module+el8.2.0+5827+8c39933c.x86_64
qemu-kvm-4.2.0-13.module+el8.2.0+5898+fb4bceae.x86_64
python ConfigTest.py --testcase=block_hotplug..fmt_raw..with_plug..with_repetition --guestname=RHEL.8.2 --clone=no
python ConfigTest.py --testcase=block_hotplug..block_scsi..fmt_raw..with_plug..with_repetition --guestname=RHEL.8.2 --clone=no


virsh define pc.xml
virsh start pc

qemu-img create -f raw /home/kvm_autotest_root/images/stg0.raw 1G
#org usage
while true;do virsh attach-device pc disk.xml; virsh detach-device pc disk.xml;done


a=1;while true;do let a=a+1;echo "a=$a";virsh attach-device pc disk.xml; ssh 192.168.122.65 lsblk /dev/sda|grep 1G && echo "ok" ||break;virsh detach-device pc disk.xml;ssh 192.168.122.65 "lsblk /dev/sda|grep 1G||echo 'detached'";done


a=1;while true;do let a=a+1;echo "a=$a";virsh attach-device pc disk.xml;virsh detach-device pc disk.xml;done

echo `date`>t;a=1;while true;do let a=a+1;echo "a=$a";if ! virsh attach-device pc disk.xml;then echo "attch wrong";break;fi ;if ! virsh detach-device pc disk.xml;then echo "detach wrong";break; fi;done;echo `date`>>t