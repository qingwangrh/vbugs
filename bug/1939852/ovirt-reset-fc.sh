#!/usr/bin/env bash
#reset
dev=$1
if [[ "x$dev" == "x" ]]; then
  echo "dev is null"
  exit 0
fi
#wipefs -a $dev
lvremove --autobackup n vg/lv1 vg/lv2 -y
vgremove vg -y
pvcreate $dev --metadatasize=1m --metadatacopies=2 --metadataignore=y
vgcreate vg $dev --physicalextentsize=1m
lvcreate --autobackup n --contiguous n  --size 512M -n lv1 vg
lvcreate --autobackup n --contiguous n  --size 512M -n lv2 vg

#lvremove vg/lv1 vg/lv2 -y;vgremove vg -y
#pvcreate $dev --metadatasize=2m --metadataignore=y
#vgcreate vg $dev --metadatasize=2m
#
#lvcreate -L 100M -n lv1 vg
#lvcreate -L 100M -n lv2 vg

qemu-img create -f qcow2 /dev/vg/lv2 200G
qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2
lvs