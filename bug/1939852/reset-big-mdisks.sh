#!/usr/bin/env bash

lvremove vg/lv1 vg/lv2 vg/lv3 vg/lv4 -y;vgremove vg -y;
  pvremove /dev/loop1;losetup -d /dev/loop1

  qemu-img create -f raw /home/lvm.img 1400G
  losetup /dev/loop1 /home/lvm.img
  pvcreate /dev/loop1 --metadatasize=4m --metadataignore=y
  vgcreate vg /dev/loop1 --metadatasize=4m
  lvcreate -L 100M -n lv1 vg
  lvcreate -L 100M -n lv2 vg
  lvcreate -L 100M -n lv3 vg
  lvcreate -L 100M -n lv4 vg

  qemu-img create -f qcow2 /dev/vg/lv2 600G
  qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2
  qemu-img create -f qcow2 /dev/vg/lv4 600G
  qemu-img create -f qcow2 /dev/vg/lv3 -b /dev/vg/lv4 -F qcow2

