#raw+pc+linux

kill -9 $(pgrep qemu-storage -a|grep qmp2.sock|cut -f 1 -d " ")
sleep 2
qemu-img create -f raw /home/kvm_autotest_root/images/winpc.raw 30G
qemu-img create -f qcow2 /home/kvm_autotest_root/images/winpc.qcow2 10G

qemu-storage-daemon \
  --chardev socket,path=/tmp/qmp2.sock,server,nowait,id=char1 \
  --monitor chardev=char1 \
  --object iothread,id=iothread0 \
  --blockdev driver=file,node-name=file0,filename=/home/kvm_autotest_root/images/winpc.raw \
  --blockdev driver=raw,node-name=fmt0,file=file0 \
  --export type=vhost-user-blk,id=export0,addr.type=unix,addr.path=/tmp/vhost-user-blk2-1.sock,node-name=fmt0,writable=on,logical-block-size=512,num-queues=1,iothread=iothread0 \
  --blockdev driver=file,node-name=file1,filename=/home/kvm_autotest_root/images/winpc.qcow2 \
  --blockdev driver=qcow2,node-name=fmt1,file=file1 \
  --export type=vhost-user-blk,id=export1,addr.type=unix,addr.path=/tmp/vhost-user-blk2-2.sock,node-name=fmt1,writable=on,logical-block-size=512,num-queues=1,iothread=iothread0 &

sleep 3

#num-queues should be same in export

/usr/libexec/qemu-kvm -enable-kvm \
  -m 4G -M memory-backend=mem \
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
  -chardev socket,path=/tmp/vhost-user-blk2-1.sock,id=vhost0 \
  -device vhost-user-blk-pci,chardev=vhost0,id=blk0,bootindex=0 \
  -chardev socket,path=/tmp/vhost-user-blk2-2.sock,id=vhost1 \
  -device vhost-user-blk-pci,chardev=vhost1,id=blk1,bootindex=1 \
  \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_may_2020_x64_dvd_5651846f.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,write-cache=on \
  -blockdev node-name=file_cd2,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd2,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd2 \
  -device ide-cd,id=cd2,drive=drive_cd2,write-cache=on \
  \
  -vnc :2 \
  -monitor stdio \
  -qmp tcp:0:5952,server,nowait

steps() {

  nc -U /tmp/qmp.sock

  {"execute":"qmp_capabilities"}
  {"execute":"query-block-exports"}

}

#kill -9 $(pgrep qemu-storage -a|grep qmp.sock|cut -f 1 -d " ")