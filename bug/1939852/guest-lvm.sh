#!/usr/bin/env bash

devs="vdb vdc vdd vde"
lvremove lv -y
vgremove vg -y
for d in $devs;do
  pvremove /dev/$d
  pvcreate /dev/$d
done

vgcreate vg /dev/vdb /dev/vdc /dev/vdd /dev/vde
lvcreate -l 100%FREE -n lv vg
lvs vg/lv

mkdir /home/test
mkfs.xfs /dev/vg/lv
mount /dev/vg/lv /home/test
mount

