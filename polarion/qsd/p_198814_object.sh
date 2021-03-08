
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk2.qcow2 2G

qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --object throttle-group,id=tg1,limits.bps-read=3000 \
  --object throttle-group,id=tg2,limits.iops-total=60,limits.iops-total-max=100,limits.iops-total-max-length=10 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/disk1.qcow2 \
  --blockdev driver=qcow2,node-name=fmt1,file=file1 \
  --blockdev driver=throttle,node-name=throttle1,throttle-group=tg1,file=fmt1 \
  --export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-user-blk1.sock,node-name=throttle1,writable=on,logical-block-size=512,num-queues=1,iothread=iothread0 \
  --blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/disk2.qcow2 \
  --blockdev driver=qcow2,node-name=fmt2,file=file2 \
  --blockdev driver=throttle,node-name=throttle2,throttle-group=tg2,file=fmt2 \
  --export type=vhost-user-blk,id=export2,addr.type=unix,addr.path=/tmp/vhost-user-blk2.sock,node-name=throttle2,writable=off,logical-block-size=1024,num-queues=2,iothread=iothread0 \


steps(){
  nc -U /tmp/qmp.sock

  {"execute":"qmp_capabilities"}
  {"execute":"query-block-exports"}
  {"execute":"qom-get","arguments":{"path":"tg1","property":"limits"}}
  {"execute":"qom-get","arguments":{"path":"tg2","property":"limits"}}
  {"execute":"query-named-block-nodes"}

}