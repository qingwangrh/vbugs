[ -e /home/kvm_autotest_root/images/data1.qcow2 ] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 1G

qemu-storage-daemon \
--blockdev file,filename=/home/kvm_autotest_root/images/data1.qcow2,node-name=proto \
--blockdev qcow2,file=proto,node-name=disk \
--export vhost-user-blk,id=exp0,addr.type=unix,addr.path=/tmp/vhost.sock,node-name=disk,writable=on \


steps() {

qemu-img create -f qcow2 /home/kvm_autotest_root/images/data1.qcow2 1G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data2.qcow2 2G

  #nc -U /tmp/qmp.sock
  #loging qemu qmp
  {"execute":"qmp_capabilities"}
  {"execute": "device_del", "arguments": {"id": "blk2"}}

  {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "blk2", "drive": "data2"}}

  }