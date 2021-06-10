#!/usr/bin/env bash
#reset
dev=$1
if [[ "x$dev" == "x" ]]; then
  echo "dev is null"
  exit 0
fi
#wipefs -a $dev
umount /home/test
lvremove --autobackup n vg/lv1 vg/lv2 -y
vgremove vg -y
pvcreate $dev --metadatasize=1m --metadatacopies=2 --metadataignore=y
vgcreate vg $dev --physicalextentsize=1m
lvcreate --autobackup n --contiguous n  --size 20G -n lv1 vg

#lvremove vg/lv1 vg/lv2 -y;vgremove vg -y
#pvcreate $dev --metadatasize=2m --metadataignore=y
#vgcreate vg $dev --metadatasize=2m
#
#lvcreate -L 512M -n lv1 vg
#lvcreate -L 512M -n lv2 vg

#qemu-img create -f qcow2 /dev/vg/lv2 200G
#qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2

mkfs.xfs /dev/vg/lv1 -f

mount /dev/vg/lv1 /home/test

for i in {1..4};do
let j=i+4
echo "$j $i"
qemu-img create -f qcow2 /home/test/stg$j.qcow2 50G
qemu-img create -f qcow2 /home/test/stg$i.qcow2 -b /home/test/stg$j.qcow2 -F qcow2
done