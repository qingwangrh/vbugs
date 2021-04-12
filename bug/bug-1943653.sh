#cache writeback
/usr/libexec/qemu-kvm \
  -name src_vm1 \
  -machine pc-q35-rhel8.3.0,accel=kvm,usb=off,dump-guest-core=off \
-m size=1024000k,slots=16,maxmem=1024000k \
-overcommit mem-lock=off \
-smp 14,maxcpus=16,sockets=16,dies=1,cores=1,threads=1 \
-object iothread,id=iothread1 \
-object memory-backend-ram,id=ram-node0,size=1024000k \
-numa node,nodeid=0,cpus=0-15,memdev=ram-node0 \
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
  \
  -object pr-manager-helper,id=pr-helper0,path=/var/run/qemu-pr-helper.sock \
  -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-8,addr=0x0 \
  -blockdev '{"driver":"host_device","filename":"/dev/mapper/mpathc","aio":"native","pr-manager":"pr-helper0","node-name":"libvirt-1-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-1-format","read-only":false,"cache":{"direct":true,"no-flush":false},"driver":"raw","file":"libvirt-1-storage"}' \
  -device scsi-block,bus=scsi1.0,channel=0,scsi-id=0,lun=25,share-rw=on,drive=libvirt-1-format,id=block1,werror=stop,rerror=stop \
  -vnc \
  :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idxgXAlm


steps() {
  #cache writeback
  #host
  mpathconf --enable
  /bin/systemctl restart multipathd.service

  systemctl start qemu-pr-helper
  systemctl status qemu-pr-helper
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

  ####host switch
  multipath-switch.sh 10

  #guest
  # dd if=/dev/zero of=/dev/sdb bs=1M count=30000
  while true; do echo "dd $(date "+%H:%M:%S")";dd if=/dev/urandom of=/dev/sdb oflag=direct bs=4k count=1000000;sleep 1; done

  host:
  systemctl status qemu-pr-helper
   strace -tt -T -v -f -o /tmp/strace.log -s 1024 -p
  iptables -A INPUT -p tcp --dport 3260 -j DROP;iptables -A INPUT -p tcp --sport 3260 -j DROP

  iptables -L -n --line-number
  iptables -D INPUT 3;iptables -D INPUT 2


  guest:
  dd if=/dev/urandom of=/dev/sdb bs=1k count=5000000 oflag=direct



}
