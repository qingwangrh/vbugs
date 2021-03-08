
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk2.qcow2 2G

qemu-storage-daemon \
--chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
--monitor chardev=char1 \
--object iothread,id=iothread0 \
--blockdev driver=file,node-name=file,filename=/home/kvm_autotest_root/images/disk1.qcow2 \
--blockdev driver=qcow2,node-name=qcow2,file=file \
--export type=vhost-user-blk,id=export,addr.type=unix,addr.path=vhost-user-blk.sock,node-name=qcow2,iothread=iothread0 \

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