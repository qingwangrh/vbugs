
kill -9 $(pgrep qemu-storage -a|grep qmp0.sock|cut -f 1 -d " ")
sleep 2
qemu-img create -f qcow2 /home/kvm_autotest_root/images/pc.qcow2 1G
qemu-img create -f raw /home/kvm_autotest_root/images/pc.raw 2G

qemu-storage-daemon \
--chardev socket,path=/tmp/qmp0.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--object iothread,id=iothread0 \
--blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/pc.qcow2 \
--blockdev driver=qcow2,node-name=fmt1,file=file1 \
--export type=vhost-user-blk,id=export1,node-name=fmt1,addr.type=unix,addr.path=/tmp/vhost-user-blk0-1.sock,iothread=iothread0 \
--blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/pc.raw \
--blockdev driver=raw,node-name=fmt2,file=file2 \
--export type=vhost-user-blk,id=export2,node-name=fmt2,addr.type=unix,addr.path=/tmp/vhost-user-blk0-2.sock,iothread=iothread0 &\


/usr/libexec/qemu-kvm -enable-kvm \
-m 4G -M pc,memory-backend=mem \
-nodefaults \
-vga qxl \
-smp 4 \
-object memory-backend-memfd,id=mem,size=4G,share=on \
-blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_image1 \
-device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=1 \
\
-chardev socket,path=/tmp/vhost-user-blk0-1.sock,id=vhost1 \
-device vhost-user-blk-pci,chardev=vhost1,id=blk1,bootindex=2 \
-chardev socket,path=/tmp/vhost-user-blk0-2.sock,id=vhost2 \
-device vhost-user-blk-pci,chardev=vhost2,id=blk2,bootindex=3 \
\
-vnc :5 \
-monitor stdio \
-qmp tcp:0:5955,server,nowait \

steps(){
  -chardev socket,path=/tmp/vhost-user-blk9-1.sock,id=vhost1 \
-device vhost-user-blk-pci,chardev=vhost1,id=blk1,bootindex=2 \
-chardev socket,path=/tmp/vhost-user-blk9-2.sock,id=vhost2 \
-device vhost-user-blk-pci,chardev=vhost2,id=blk2,bootindex=3 \
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