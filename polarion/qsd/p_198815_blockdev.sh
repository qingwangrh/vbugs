kill -9 $(pgrep qemu-storag)
sleep 2
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G
qemu-img create -f raw /home/kvm_autotest_root/images/disk2.raw 2G

qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/disk1.qcow2,aio=native,locking=on,read-only=on,auto-read-only=on,force-share=on,cache.direct=on,cache.no-flush=off,detect-zeroes=on,discard=unmap \
  --blockdev driver=qcow2,node-name=fmt1,file=file1,lazy-refcounts=on,overlap-check=none,cache-size=16777216,read-only=on,auto-read-only=on,force-share=on,cache.direct=on,cache.no-flush=off,detect-zeroes=on,discard=unmap \
  --export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-user-blk1.sock,node-name=fmt1,writable=off,logical-block-size=512,num-queues=1,iothread=iothread0 \
  \
  --blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/disk2.raw,aio=threads,locking=off,read-only=off,auto-read-only=off,force-share=off,cache.direct=on,cache.no-flush=off,detect-zeroes=off,discard=ignore \
  --blockdev driver=raw,node-name=fmt2,file=file2,read-only=off,auto-read-only=off,force-share=off,cache.direct=on,cache.no-flush=off,detect-zeroes=on,discard=unmap \
  --export type=vhost-user-blk,id=export2,addr.type=unix,addr.path=/tmp/vhost-user-blk2.sock,node-name=fmt2,writable=on,logical-block-size=1024,num-queues=2,iothread=iothread0 \


steps(){
  nc -U /tmp/qmp.sock

  {"execute": "qmp_capabilities"}
  {"execute":"query-block-exports"}

}