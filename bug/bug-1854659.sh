#cache writeback
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
  -device pcie-root-port,id=pcie.0-root-port-7,slot=7,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  -blockdev \
  driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.qcow2,node-name=drive_image1 \
  -device scsi-hd,id=os1,drive=drive_image1,bootindex=0 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev node-name=host_device_stg0,driver=host_device,filename=/dev/mapper/mpathb \
  -blockdev node-name=drive_stg0,driver=raw,file=host_device_stg0 \
  -device scsi-generic,id=stg0,drive=drive_stg0,bus=scsi1.0,bootindex=2 \
  -vnc \
  :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm

steps() {
  #cache writeback
  #host
  mpathconf --enable
  /bin/systemctl restart multipathd.service
  #test on host
  while true; do
    echo "dd start $(date "+%H:%M:%S")"
    dd if=/dev/urandom of=/dev/mapper/mpatha oflag=direct bs=4k count=10000
    echo "dd end $(date "+%H:%M:%S")"
    sleep 1
  done
  # host create multipath device
  multipath -f /dev/mapper/mpathb
  modprobe -r scsi_debug
  modprobe scsi_debug dev_size_mb=5000 num_tgts=1 vpd_use_hostno=0 add_host=2 delay=1 max_luns=2 no_lun_0=1

  multipath-switch.sh 10

  #guest
  # dd if=/dev/zero of=/dev/sdb bs=1M count=30000
  while true; do echo "dd $(date "+%H:%M:%S")";dd if=/dev/urandom of=/dev/sdb oflag=direct bs=4k count=1000000;sleep 1; done

  #hit io-error
  -device scsi-block,id=stg0,rerror=stop,werror=stop,drive=drive_stg0,bus=scsi1.0,bootindex=2 \
  -device scsi-generic,id=stg0,drive=drive_stg0,bus=scsi1.0,bootindex=2 \
  #not hit io-error (not sure)
  #it need to add no_path_retry 1 into multipath.conf
  -device scsi-hd,id=stg0,drive=drive_stg0,rerror=stop,werror=stop,bootindex=2 \
  -device virtio-blk-pci,scsi=off,bus=pcie.0-root-port-4,addr=0,drive=drive_stg0,id=stg0,write-cache=on,rerror=stop,werror=stop,bootindex=2 \
  #{"execute":"qmp_capabilities"}
  #{"execute":"device_del","arguments":{"id":"stg1"}}
  #
  #system_reset
  #{"execute":"device_add","arguments":{"driver":"scsi-block","drive":"drive_stg1","bus":"scsi1.0"}}

}
