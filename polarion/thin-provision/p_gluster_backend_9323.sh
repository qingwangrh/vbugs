/usr/libexec/qemu-kvm \
  -name 'avocado-vt-vm1' \
  -machine q35 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x1 \
  -device pvpanic,ioport=0x505,id=idZcGD6F \
  -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
  -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
  -device pcie-root-port,id=pcie.0-root-port-6,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-4,addr=0x0 \
  -device virtio-scsi-pci,id=scsi2,bus=pcie.0-root-port-6,addr=0x0 \
  -blockdev \
  driver=file,cache.direct=off,cache.no-flush=on,filename=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2,node-name=host_disk2 \
  -blockdev driver=qcow2,node-name=disk_2,file=host_disk2 \
  -device scsi-hd,drive=disk_2,bus=scsi0.0,id=host_disk_2 \
  \
  -blockdev driver=gluster,cache.direct=on,cache.no-flush=off,volume=gv0,path=test.qcow2,server.0.type=inet,server.0.host=gluster-virt-qe-01.lab.eng.pek2.redhat.com,server.0.port=24007,node-name=data_disk,discard=unmap \
  -blockdev driver=qcow2,node-name=disk1,file=data_disk,cache.direct=on,cache.no-flush=off,discard=unmap \
  -device scsi-hd,drive=disk1,bus=scsi2.0,id=data_disk,write-cache=on \
  -device \
  pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
  -device \
  virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0 \
  -netdev tap,id=idGRsMas,vhost=on \
  -m 13312 \
  -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso \
  -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
  -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-176.iso \
  -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0 \
  -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
  -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.2,unit=0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -vnc :5 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot order=cdn,once=c,menu=off,strict=off \
  -enable-kvm \
  -device pcie-root-port,id=pcie_extra_root_port_0,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -monitor stdio \
  -qmp tcp:0:5955,server,nowait

steps() {

#  -blockdev driver=file,filename=/mnt/gluster/test.qcow2,node-name=data_disk,discard=unmap \
#    -blockdev driver=gluster,cache.direct=on,cache.no-flush=off,volume=gv0,path=test.qcow2,server.0.type=inet,server.0.host=gluster-virt-qe-01.lab.eng.pek2.redhat.com,server.0.port=24007,node-name=data_disk,discard=unmap \
#    -blockdev driver=qcow2,node-name=disk1,file=data_disk,cache.direct=on,cache.no-flush=off,discard=unmap \
#    -device scsi-hd,drive=disk1,bus=scsi2.0,id=data_disk,write-cache=on
  #host
  yum install glusterfs glusterfs-cli glusterfs-client-xlators glusterfs-fuse -y
  qemu-img create -f qcow2 gluster://gluster-virt-qe-01.lab.eng.pek2.redhat.com/gv0/test.qcow2 1G
  mount.glusterfs gluster-virt-qe-01.lab.eng.pek2.redhat.com:/gv0 /mnt/gluster
  #guest

  mkfs.ext4 /dev/sdb
  mkdir /mnt/test
  mount /dev/sdb /mnt/test
  dd if=/dev/zero of=/mnt/test/file bs=1M count=500

  rm /mnt/test/file
  fstrim /mnt/test
  #host
  stat /mnt/gluster/test.qcow2

}
