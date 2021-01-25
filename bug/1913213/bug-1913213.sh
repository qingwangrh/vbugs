#nfs


/usr/libexec/qemu-kvm \
  -name nfs-vm \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0,multifunction=on \
  -device pcie-root-port,id=pcie.0-root-port-2-1,chassis=3,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,id=pcie.0-root-port-2-2,chassis=4,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-9,slot=9,bus=pcie.0 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso  \
  -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
  -drive id=drive_cd2,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
 -device ide-cd,id=cd2,drive=drive_cd2,bus=ide.1,unit=0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-2-2,addr=0x0,iothread=iothread0 \
  \
  -blockdev driver=file,filename=/home/kvm_autotest_root/images1/rhel840-64-virtio.qcow2,node-name=libvirt-1-storage,cache.direct=on,cache.no-flush=off,auto-read-only=on,discard=unmap \
  -blockdev node-name=libvirt-1-format,read-only=off,discard=unmap,cache.direct=on,cache.no-flush=off,driver=qcow2,file=libvirt-1-storage \
  -device virtio-blk-pci,bus=pcie.0-root-port-4,addr=0x0,drive=libvirt-1-format,id=virtio-disk0,bootindex=1,write-cache=on,werror=stop,rerror=stop \
  -vnc :5 \
  -qmp tcp:0:5955,server,nowait \
  -monitor stdio \
  -m 4096 \
  -smp 8 \
  \
  -device virtio-net-pci,mac=9a:52:fd:51:01:1d,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \


  steps(){

    while true;do dd if=/dev/urandom of=test.img bs=4k count=25600 oflag=direct iflag=fullblock;sync;sleep 2;rm -rf test.img;fstrim ./;sync; done
    #reject
    iptables -t filter -A OUTPUT -d 10.73.114.93 -m state --state NEW,RELATED,ESTABLISHED -p tcp --dport 2049 -j REJECT
    #reconnect
    iptables -t filter -D OUTPUT -d 10.73.114.93 -m state --state NEW,RELATED,ESTABLISHED -p tcp --dport 2049 -j REJECT
  }