

qmpsocks="qmp1.sock qmp2.sock"
for qmpsock in $qmpsocks;do
if pgrep qemu-storage -a|grep $qmpsock;then
  echo "kill  $qmpsock"
  kill -9 $(pgrep qemu-storage -a|grep $qmpsock|cut -f 1 -d " ")
  sleep 2
fi
done

f1=/home/kvm_autotest_root/images/nbd1.qcow2
f2=/home/kvm_autotest_root/images/nbd2.qcow2
[[ -e $f1 ]] || qemu-img create -f qcow2 $f1 1G
[[ -e $f2 ]] || qemu-img create -f qcow2 $f2 2G


#qcow2 and luks must be export by raw
qemu-storage-daemon \
--chardev socket,path=/tmp/qmp1.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/nbd1.qcow2 \
--blockdev driver=raw,node-name=fmt1,file=file1 \
--nbd-server addr.type=unix,addr.path=/tmp/nbd1.sock \
--export type=nbd,id=export1,node-name=fmt1,writable=on,name=nbdunix &\


qemu-storage-daemon \
--chardev socket,path=/tmp/qmp2.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/nbd2.qcow2 \
--blockdev driver=raw,node-name=fmt2,file=file2 \
--nbd-server addr.type=inet,addr.host=0.0.0.0,addr.port=9000,max-connections=10 \
--export type=nbd,id=export2,node-name=fmt2,writable=on,name=nbdinet & \

for qmpsock in $qmpsocks;do
pgrep qemu-storage -a|grep $qmpsock
done
sleep 2

/usr/libexec/qemu-kvm -enable-kvm \
-m 4G -M pc,memory-backend=mem \
-nodefaults \
-vga qxl \
-smp 4 \
-object memory-backend-memfd,id=mem,size=4G,share=on \
-blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_image1 \
-device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=0 \
\
-blockdev node-name=nbd_unix,driver=nbd,export=nbdunix,server.path=/tmp/nbd1.sock,server.type=unix \
-blockdev node-name=fmt1,driver=qcow2,file=nbd_unix \
-device virtio-blk-pci,id=blk1,drive=fmt1,bootindex=1 \
\
-blockdev node-name=nbd_inet,driver=nbd,export=nbdinet,server.host=127.0.0.1,server.port=9000,server.type=inet \
-blockdev node-name=fmt2,driver=qcow2,file=nbd_inet \
-device virtio-blk-pci,id=blk2,drive=fmt2,bootindex=2 \
-vnc :5 \
-monitor stdio \
-qmp tcp:0:5955,server,nowait \

steps(){

  nc -U /tmp/qmp.sock

  {"execute":"qmp_capabilities"}
  {"execute":"query-block-exports"}
  {"execute":"block-export-del", "arguments": {"id": "export"}}
  {"execute":"query-block-exports"}

  {"execute":"query-named-block-nodes"}
  {"execute":"blockdev-del", "arguments": {"node-name": "qcow2"}}
  {"execute":"blockdev-del", "arguments": {"node-name": "file"}}
  {"execute":"query-named-block-nodes"}

  {"execute": "object-del", "arguments": {"id": "iothread0"}}
  {"execute": "object-add", "arguments": {"qom-type": "iothread", "id": "iothread0"}}
  {'execute': 'object-add', 'arguments': {'qom-type': 'throttle-group', 'id': 'tg0', 'props': {'limits': {'iops-total': 50}}}}

  {"execute": "blockdev-add", "arguments": {"node-name": "file", "driver": "file", "auto-read-only": true, "discard": "unmap", "aio": "threads", "filename": "/home/kvm_autotest_root/images/disk.qcow2", "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "qcow2", "driver": "qcow2", "file": "file", "read-only": false, "cache": {"direct": true, "no-flush": false}}}
  {"execute": "blockdev-add", "arguments": {"node-name": "throttle", "driver": "throttle", "throttle-group": "tg0", "file": "qcow2"}}
  {"execute":"query-named-block-nodes"}

  {"execute": "block-export-add", "arguments": {"type": "vhost-user-blk", "id": "export", "node-name": "throttle", "addr": { "type": "unix", "path": "'vhost-user-blk.sock"},"iothread":"iothread0"}}
  {"execute":"query-block-exports"}

  {"execute": "block-export-del", "arguments": {"id": "export"}}
  {"execute":"query-block-exports"}

  {"execute": "blockdev-del", "arguments": {"node-name": "throttle"}}
  {"execute": "blockdev-del", "arguments": {"node-name": "qcow2"}}
  {"execute": "blockdev-del", "arguments": {"node-name": "file"}}
  {"execute":"query-named-block-nodes"}

  {"execute": "object-del", "arguments": {"id": "iothread0"}}
  {"execute": "object-del", "arguments": {"id": "tg0"}}

  {"execute":"qom-list","arguments":{"path":"iothread0"}}
  {"execute":"qom-list","arguments":{"path":"tg0"}}


}