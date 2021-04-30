#!/usr/bin/env bash

umount /home/test

rm /home/test -rf ;mkdir -p /home/test
lvremove vg/lv1 -y
vgremove vg -y
qemu-img create -f raw /home/lvm.img 200G
losetup /dev/loop1 /home/lvm.img
pvcreate /dev/loop1 --metadatasize=2m --metadataignore=y
vgcreate vg /dev/loop1 --metadatasize=2m
lvcreate -L 1G -n lv1 vg


mkfs.xfs /dev/vg/lv1
mount /dev/vg/lv1 /home/test
for i in {1..8};do
qemu-img create -f qcow2 /home/test/stg$i.qcow2 50G
done



#vgcreate vg /dev/loop1 --metadatasize=2m
#lvcreate -L 100M -n lv1 vg
#lvcreate -L 100M -n lv2 vg
#
#qemu-img create -f qcow2 /dev/vg/lv2 100G
#qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2
