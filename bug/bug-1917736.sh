#native+iothread

/usr/libexec/qemu-kvm -name guest=openshift-cnv_rhel8,debug-threads=on \
  -smp 1,sockets=1,dies=1,cores=1,threads=1 \
  -object iothread,id=iothread1 \
  -uuid 343d03eb-fd91-5b46-ba85-b34ea40c6123 \
  -machine pc-q35-rhel8.2.0,accel=kvm,usb=off,dump-guest-core=off \
  -no-user-config \
  -nodefaults \
  -rtc base=utc -no-shutdown -boot strict=on \
  -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
  -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 \
  -device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
  -device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 \
  -device pcie-root-port,port=0x14,chassis=5,id=pci.5,bus=pcie.0,addr=0x2.0x4 \
  -device pcie-root-port,port=0x15,chassis=6,id=pci.6,bus=pcie.0,addr=0x2.0x5 \
  -device pcie-root-port,port=0x16,chassis=7,id=pci.7,bus=pcie.0,addr=0x2.0x6 \
  -device pcie-root-port,port=0x17,chassis=8,id=pci.8,bus=pcie.0,addr=0x2.0x7 \
  -device pcie-root-port,port=0x18,chassis=9,id=pci.9,bus=pcie.0,addr=0x3 \
  -device virtio-scsi-pci,id=scsi0,bus=pci.2,addr=0x0 \
  -device virtio-serial-pci,id=virtio-serial0,bus=pci.3,addr=0x0 \
  -blockdev \
  '{"driver":"file","filename":"/home/kvm_autotest_root/images/rhel830-64-virtio-scsi.raw","node-name":"libvirt-3-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-3-format","read-only":false,"cache":{"direct":true,"no-flush":false},"driver":"raw","file":"libvirt-3-storage"}' \
  -device virtio-blk-pci,iothread=iothread1,bus=pci.4,addr=0x0,drive=libvirt-3-format,id=ua-rootdisk,bootindex=1,write-cache=on \
  -blockdev \
  '{"driver":"file","filename":"/home/kvm_autotest_root/images/win.iso","node-name":"libvirt-2-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-2-format","read-only":true,"cache":{"direct":true,"no-flush":false},"driver":"raw","file":"libvirt-2-storage"}' \
  -device virtio-blk-pci,iothread=iothread1,bus=pci.5,addr=0x0,drive=libvirt-2-format,id=ua-cloudinitdisk,write-cache=on \
  -blockdev \
  '{"driver":"host_device","filename":"/dev/mapper/mpatha","aio":"native","node-name":"libvirt-1-storage","cache":{"direct":true,"no-flush":false},"auto-read-only":true,"discard":"unmap"}' \
  -blockdev '{"node-name":"libvirt-1-format","read-only":false,"cache":{"direct":true,"no-flush":false},"driver":"raw","file":"libvirt-1-storage"}' \
  -device virtio-blk-pci,iothread=iothread1,bus=pci.6,addr=0x0,drive=libvirt-1-format,id=ua-disk-0,write-cache=on \
  -vnc :5 \
  -device VGA,id=video0,vgamem_mb=16,bus=pcie.0,addr=0x1 \
  -qmp tcp:0:5955,server,nowait \
  -m 8192 \
  -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b5,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pci.1,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -monitor stdio \


steps(){
echo
/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_may_2020_x64_dvd_5651846f.iso
/home/kvm_autotest_root/images/win.iso

}