# This is win domain server depend on virbr0
#192.168.122.100
#WQTEST\Administrator Kvm_autotest

winos_iso=$(readlink /home/kvm_autotest_root/iso/ISO/Win2019/latest_x86_64/* -f)

/usr/libexec/qemu-kvm \
  -name 'wqdomain-pub' \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x1 \
  -device pvpanic,ioport=0x505,id=idZcGD6F \
  -device pcie-root-port,id=pcie-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-2,addr=0x0 \
  -device pcie-root-port,id=pcie-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device pcie-root-port,id=pcie-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device pcie-root-port,id=pcie-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
  -device pcie-root-port,id=pcie-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-3,addr=0x0 \
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-4,addr=0x0 \
  -blockdev driver=file,node-name=file_disk,cache.direct=off,cache.no-flush=on,filename=/home/windbg/pub-dserver.qcow2 \
  -blockdev driver=qcow2,node-name=protocol_disk,file=file_disk \
  -device scsi-hd,drive=protocol_disk,bus=scsi0.0,id=os_disk,bootindex=1 \
  -device virtio-net-pci,mac=9a:95:96:97:98:90,id=idKSMZST,netdev=idWCSiU5,bus=pcie-root-port-6,addr=0x0 \
  -netdev tap,id=idWCSiU5,script=/etc/qemu-ifup,vhost=on \
  -m 8G \
  -smp 24,maxcpus=24,cores=12,threads=1,sockets=2 \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=${winos_iso},cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=ide.0,unit=0 \
  -blockdev node-name=file_cd2,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd2,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd2 \
  -device ide-cd,id=cd2,drive=drive_cd2,write-cache=on,bus=ide.1,unit=0 \
  -blockdev node-name=file_cd3,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd3,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd3 \
  -device ide-cd,id=cd3,drive=drive_cd3,write-cache=on,bus=ide.2,unit=0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :9 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -enable-kvm \
  -monitor stdio \
  -qmp tcp:0:5959,server,nowait \



steps() {
#this server should using static ip. 10.73.198.60
#first run with dhcp in guest,then set the ip as static
ip 10.73.199.187
mask 255.255.252.0
gatway 10.73.199.254
dns:127.0.0.1,10.73.2.107

#  -device virtio-net-pci,mac=9a:55:56:57:58:61,id=id18Xcuo,netdev=idGRsMas,bus=pcie-root-port-5,addr=0x0 \
#    -netdev tap,id=idGRsMas,vhost=on \
#    echo

}
