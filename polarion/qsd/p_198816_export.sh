kill -9 $(pgrep qemu-storag)
sleep 2
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk2.qcow2 2G

#pkill qemu-storage-daemon

qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --blockdev driver=file,node-name=file0,filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2 \
  --blockdev driver=qcow2,node-name=fmt0,file=file0 \
  --export type=vhost-user-blk,id=export0,addr.type=unix,addr.path=/tmp/vhost-user-blk0.sock,node-name=fmt0,writable=on,logical-block-size=512,num-queues=1,iothread=iothread0 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/disk1.qcow2 \
  --blockdev driver=qcow2,node-name=fmt1,file=file1 \
  --export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-user-blk1.sock,node-name=fmt1,writable=on,logical-block-size=512,num-queues=1,iothread=iothread0 \
  --blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/disk2.qcow2 \
  --blockdev driver=qcow2,node-name=fmt2,file=file2 \
  --export type=vhost-user-blk,id=export2,addr.type=unix,addr.path=/tmp/vhost-user-blk2.sock,node-name=fmt2,writable=off,logical-block-size=1024,num-queues=2,iothread=iothread0 &

sleep 3

#num-queues should be same in export

/usr/libexec/qemu-kvm -enable-kvm \
-m 4G -M memory-backend=mem \
-nodefaults \
-vga qxl \
-smp 4 \
-object memory-backend-memfd,id=mem,size=4G,share=on \
-chardev socket,path=/tmp/vhost-user-blk0.sock,id=vhost0 \
-device vhost-user-blk-pci,chardev=vhost0,id=blk0,bootindex=0 \
-chardev socket,path=/tmp/vhost-user-blk1.sock,id=vhost1 \
-device vhost-user-blk-pci,chardev=vhost1,id=blk1,bootindex=1 \
-chardev socket,path=/tmp/vhost-user-blk2.sock,id=vhost2 \
-device vhost-user-blk-pci,chardev=vhost2,id=blk2,bootindex=2,num-queues=2 \
-vnc :5 \
-monitor stdio \
-qmp tcp:0:5955,server,nowait \

steps(){

  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_image1 \
-device virtio-blk-pci,id=blk_data1,drive=os_image1,bootindex=1 \

  nc -U /tmp/qmp.sock

  {"execute":"qmp_capabilities"}
  {"execute":"query-block-exports"}

}