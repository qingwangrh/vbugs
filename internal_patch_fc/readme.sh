#git diff > qemu_vm.patch
#git apply --whitespace=fix qemu_vm.patch
#cp * /workdir/kar/tp-qemu/qemu/tests/ -rf
#cp /home/rworkdir/vbugs/internal_patch_fc/* /workdir/kar/tp-qemu/qemu/tests/ -rf
#
#(workspace) root@dell-per440-08 /workdir/kar #
#python ConfigTest.py --testcase=multipath_offline_running --guestname=RHEL.8.2 --driveformat=virtio_scsi --imageformat=qcow2 --clone=no
#
#dell-per440-07.lab.eng.pek2.redhat.com
#special_host = "dell-per440-08.lab.eng.pek2.redhat.com"
#stg_serial_name = "360050763008084e6e0000000000001a4"

wfc_patch() {
  cd /workdir/kar/avocado-vt/virttest
  git apply --whitespace=fix /home/rworkdir/vbugs/internal_patch_fc/qemu_vm_qcontainer.patch
  git st ./
  cd -
}

wfc_cp() {
  echo "usage: $0 host serial mpatha"
  if [[ "x$1" != "x" ]]; then
    host=$1
    serial=$2
    image_name_stg=$3

    cmd="sed -i -e '1,\$s/special_host.*/special_host = $1/g' -e '1,\$s/stg_serial_name.*/stg_serial_name = $2/g' "

    if [[ "x$3" != "x" ]]; then
      cmd="$cmd  -e '1,\$s/image_name_stg.*mapper.*/image_name_stg = \"\/dev\/mapper\/$3\"/g' "
    fi

    cmd="$cmd cfg/*.cfg"

    echo
    echo "$cmd"
    eval $cmd
  fi
  echo "copy...."
  yes | cp /home/rworkdir/vbugs/internal_patch_fc/* /workdir/kar/tp-qemu/qemu/tests/ -rf
  yes | cp fc.cfg.sav /workdir/kar/internal_cfg/test_loops/fc.cfg

  #wsed dell-per440-07.lab.eng.pek2.redhat.com  360050763008084e6e0000000000001a5 mpatha

}

steps() {
  systemctl status qemu-pr-helper
  systemctl start qemu-pr-helper

  python ConfigTest.py --category=fc --guestname=RHEL.8.3.0 --driveformat=virtio_scsi --machines=q35 --clone=no
  #https://docs.google.com/spreadsheets/d/11roIAL10e_pW9LJD8V31iXqe-yP61zAc/edit#gid=2022141352
  #114478
  python ConfigTest.py --testcase=block_device_with_rotational --guestname=RHEL.8.2 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --clone=no
  #150370
  python ConfigTest.py --testcase=passthrough_disk_limits_io_write --guestname=RHEL.8.2 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --clone=no
  #151033,151062
  python ConfigTest.py --testcase=multipath_offline_running --guestname=RHEL.8.2,Win2019 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --platform=x86_64 --clone=yes
  #85845
  python ConfigTest.py --testcase=dd_passthrough_disk_via_EmulexHBA --guestname=RHEL.8.2.0 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --clone=no

  #113695
  python ConfigTest.py --testcase=multipath_persistent_reservation --guestname=RHEL.8.2.0 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --clone=no

  python3 ConfigTest.py --testcase=fc_storage_corrupt --guestname=RHEL.8.2.0 --driveformat=virtio_scsi --nicmodel=virtio_net --imageformat=qcow2 --machines=q35 --clone=no

}
