
if pgrep qemu-storage -a|grep qmp.sock;then
  kill -9 $(pgrep qemu-storage -a|grep qmp.sock|cut -f 1 -d " ")
  sleep 2
fi

qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/disk1.qcow2 \
  --blockdev driver=qcow2,node-name=fmt1,file=file1 \
  --export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-user-blk1.sock,node-name=fmt1,writable=on,iothread=iothread0 \
  --blockdev driver=file,node-name=file2,filename=/home/kvm_autotest_root/images/disk2.raw \
  --blockdev driver=raw,node-name=fmt2,file=file2 \
  --export type=vhost-user-blk,id=export2,addr.type=unix,addr.path=/tmp/vhost-user-blk2.sock,node-name=fmt2,writable=on,iothread=iothread0 &

sleep 3

#num-queues should be same in export

/usr/libexec/qemu-kvm -enable-kvm \
  -m 4G -M accel=kvm,memory-backend=mem \
  -nodefaults \
  -vga qxl \
  -smp 4 \
  -object memory-backend-memfd,id=mem,size=4G,share=on \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pci.0,addr=0x3,chassis=1 \
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=pci.0,chassis=2 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=pci.0,chassis=3 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=pci.0,chassis=4 \
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=pci.0,chassis=5 \
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=pci.0,chassis=6 \
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=pci.0,chassis=7 \
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=pci.0,chassis=8 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 \
  -blockdev driver=qcow2,file.driver=file,file.filename=/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2,node-name=os_image1 \
  -device virtio-blk-pci,id=blk0,drive=os_image1,bootindex=0 \
  -chardev socket,path=/tmp/vhost-user-blk1.sock,id=vhost1 \
  -device vhost-user-blk-pci,chardev=vhost1,id=blk1,bootindex=1 \
  -chardev socket,path=/tmp/vhost-user-blk2.sock,id=vhost2 \
  -device vhost-user-blk-pci,chardev=vhost2,id=blk2,bootindex=2 \
  \
  -vnc :5 \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait

steps() {

qemu-img create -f qcow2 /home/kvm_autotest_root/images/disk1.qcow2 1G
qemu-img create -f raw /home/kvm_autotest_root/images/disk2.raw 2G

  #nc -U /tmp/qmp.sock
  #loging qemu qmp
  {"execute":"qmp_capabilities"}
  {"execute":"query-block-exports"}
  {"execute": "device_del", "arguments": {"id": "blk2"}}

  {"execute": "chardev-remove", "arguments": {"id": "vhost2"}}

  {"execute": "chardev-add", "arguments": {"id": "vhost2","backend":{"type":"socket","data":{"addr":{"type":"unix","data":{"path":"/tmp/vhost-user-blk2.sock"}},"server":false}}}}

  {"execute": "device_add", "arguments": {"driver": "vhost-user-blk-pci", "id": "blk2", "chardev": "vhost2"}}

}

