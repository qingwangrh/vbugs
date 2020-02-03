
#only Raw
/usr/libexec/qemu-kvm \
  -name src_vm1 \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL7.8-Server-x86_64.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/images/rhel810-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  \
  -device virtio-scsi-pci,id=scsi1,bus=,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev driver=raw,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.raw,node-name=drive2,file.driver=file \
  -device scsi-hd,drive=drive2,id=data-disk1,bus=scsi1.0,serial=test,share-rw=on \
  -device virtio-scsi-pci,id=scsi2,bus=,bus=pcie.0-root-port-9,addr=0x0 \
  -blockdev driver=raw,cache.direct=off,cache.no-flush=on,file.filename=/home/images/data1.raw,node-name=drive3,file.driver=file \
  -device scsi-hd,drive=drive3,id=data-disk2,bus=scsi2.0,serial=test,share-rw=on \
  \
  \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm \



steps() {

  #Guest
  /lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sdb
  /lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/sdc

#change /etc/multipath.conf
#  defaults  {
#        user_friendly_names yes
#        find_multipaths yes
#        enable_foreign "^$"
#        getuid_callout "/lib/udev/scsi_id --whitelisted --replace-whitespace --device=/dev/%n"
#}
#
#blacklist_exceptions {
#        property "(SCSI_IDENT_|ID_WWN)"
#}
#
#blacklist {
#}
#
#multipaths {
#multipath {
#wwid  0QEMU_QEMU_HARDDISK_test     // wwid of /dev/sdb|sdc
#alias sluo-sd
#path_grouping_policy multibus
#path_selector "round-robin 0"
#}
#}

#multipath -l
#sluo-sd (0QEMU_QEMU_HARDDISK_test) dm-2 QEMU,QEMU HARDDISK
#size=1.0G features='0' hwhandler='0' wp=rw
#`-+- policy='round-robin 0' prio=0 status=active
#  |- 1:0:0:0 sdb 8:16 active undef running
#  `- 2:0:0:0 sdc 8:32 active undef running


 dd if=/dev/urandom of=/dev/mapper/sluo-sd bs=1M count=1000
 iostat -x sdb sdc 2

 system_reset
}

