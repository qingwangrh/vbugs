#!/usr/bin/env bash

lvremove vg/lv1 vg/lv2 -y;vgremove vg -y;
  pvremove /dev/loop1;losetup -d /dev/loop1

  qemu-img create -f raw /home/lvm.img 110G
  losetup /dev/loop1 /home/lvm.img
  pvcreate /dev/loop1 --metadatasize=2m --metadataignore=y
  vgcreate vg /dev/loop1 --metadatasize=2m
  lvcreate -L 100M -n lv1 vg
  lvcreate -L 100M -n lv2 vg

  qemu-img create -f qcow2 /dev/vg/lv2 10G
  qemu-img create -f qcow2 /dev/vg/lv1 -b /dev/vg/lv2 -F qcow2

