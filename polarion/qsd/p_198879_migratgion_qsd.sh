

qmpsocks="qmpsrc.sock qmpdst.sock"
for qmpsock in $qmpsocks;do
if pgrep qemu-storage -a|grep $qmpsock;then
  echo "kill  $qmpsock"
  kill -9 $(pgrep qemu-storage -a|grep $qmpsock|cut -f 1 -d " ")
  sleep 2
fi
done

f1=/home/kvm_autotest_root/images/disk1.qcow2
f2=/home/kvm_autotest_root/images/disk2.qcow2
[[ -e $f1 ]] || qemu-img create -f qcow2 $f1 1G
[[ -e $f2 ]] || qemu-img create -f qcow2 $f2 2G


src(){

qemu-storage-daemon --chardev socket,path=/tmp/qmpsrc.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--blockdev driver=file,node-name=file1,filename=/home/nfs/disk1.qcow2,locking=off \
--blockdev driver=qcow2,node-name=fmt1,file=file1 \
--export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-src-blk1.sock,node-name=fmt1,writable=on


qemu-storage-daemon --chardev socket,path=/tmp/qmpdst.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--blockdev driver=file,node-name=file1,filename=/home/nfs/disk1.qcow2,locking=off \
--blockdev driver=qcow2,node-name=fmt1,file=file1 \
--export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-dst-blk1.sock,node-name=fmt1,writable=on

qmpsock=qmpsrc.sock
pgrep qemu-storage -a|grep $qmpsock


/usr/libexec/qemu-kvm -enable-kvm   \
-m 4G -M q35,accel=kvm,memory-backend=mem   \
-nodefaults   -vga qxl   \
-object memory-backend-memfd,id=mem,size=4G,share=on   \
 pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x3,chassis=1   \
 -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pcie.0,chassis=2   \
 -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pcie.0,chassis=3     \
 -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0   \
 -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1   \
 -blockdev driver=qcow2,file.driver=file,file.filename=/home/nfs/rhel840-64-virtio-scsi.qcow2,node-name=os_image1   \
 -device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=0     \
 -chardev socket,path=/tmp/vhost-src-blk1.sock,id=vhost1   \
 -device vhost-user-blk-pci,chardev=vhost1,id=blk1,bus=pcie-root-port-2,addr=0x0,num-queues=1,bootindex=1     \
 -monitor stdio   -vnc :5   -qmp tcp:0:5955,server,nowait



/usr/libexec/qemu-kvm -enable-kvm   \
-m 4G -M q35,accel=kvm,memory-backend=mem   \
-nodefaults   -vga qxl   -object memory-backend-memfd,id=mem,size=4G,share=on   \
-device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x3,chassis=1   \
-device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pcie.0,chassis=2   \
-device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pcie.0,chassis=3     \
-device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0   \
-device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1   \
-blockdev driver=qcow2,file.driver=file,file.filename=/home/nfs/rhel840-64-virtio-scsi.qcow2,node-name=os_image1   \
-device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=0     \
-chardev socket,path=/tmp/vhost-dst-blk1.sock,id=vhost1   \
-device vhost-user-blk-pci,chardev=vhost1,id=blk1,bus=pcie-root-port-2,addr=0x0,num-queues=1,bootindex=1     \
-monitor stdio   -vnc :6   -qmp tcp:0:5956,server,nowait   -incoming defer

#qsd

#qcow2: Marking image as corrupt: Data cluster offset 0xcc3839475b2800 unaligned (guest offset: 0x43c4c400); further corruption events will be suppressed
}


steps() {

  migrate_incoming tcp:[::]:5000
  migrate_set_capability postcopy-ram on

  migrate_set_capability postcopy-ram on
  migrate -d tcp:127.0.0.1:5000
  migrate_start_postcopy

  migrate_set_capability postcopy-ram on
  migrate -d tcp:10.73.196.25:5000
  migrate_start_postcopy

}

