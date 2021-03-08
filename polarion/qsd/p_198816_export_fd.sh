
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G

python3 openfd.py \
qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/disk1.qcow2 \
  --blockdev driver=qcow2,node-name=fmt1,file=file1 \
  --export type=vhost-user-blk,id=export,addr.type=fd,addr.str=3,node-name=fmt1,writable=off,logical-block-size=4096,num-queues=2,iothread=iothread0


steps(){
  nc -U /tmp/qmp.sock

  {"execute": "qmp_capabilities"}
  {"execute":"query-block-exports"}

}