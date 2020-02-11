/usr/libexec/qemu-kvm \
-name guest=ELKLC01,debug-threads=on \
-machine pc-i440fx-rhel7.6.0,accel=kvm,usb=off,dump-guest-core=off \
-cpu Haswell-noTSX \
-m size=4096m,slots=16,maxmem=31220m \
-realtime mlock=off \
-smp 8,maxcpus=16,sockets=16,cores=1,threads=1 \
-object iothread,id=iothread1 \
-uuid 4b77e47d-12c4-450c-93a0-d5c7c1cd1564 \
-smbios 'type=1,manufacturer=Red Hat,product=RHEV Hypervisor,version=7.7-10.el7,serial=30393137-3436-584D-5136-313930325648,uuid=4b77e47d-12c4-450c-93a0-d5c7c1cd1564' \
-no-user-config \
-nodefaults \
-global kvm-pit.lost_tick_policy=delay \
-no-hpet \
-no-shutdown \
-global PIIX4_PM.disable_s3=1 \
-global PIIX4_PM.disable_s4=1 \
-boot strict=on \
-device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 \
-device virtio-scsi-pci,iothread=iothread1,id=ua-3da5fd68-1257-42e1-b1a1-c72abdb5325d,bus=pci.0,addr=0x5 \
-device virtio-serial-pci,id=ua-30e74395-aaef-49e8-baf8-e58d144d48f7,max_ports=16,bus=pci.0,addr=0x4 \
-drive if=none,id=drive-ua-839818aa-ca63-4c03-b14a-f5b4eca67fce,werror=report,rerror=report,readonly=on \
-device ide-cd,bus=ide.1,unit=0,drive=drive-ua-839818aa-ca63-4c03-b14a-f5b4eca67fce,id=ua-839818aa-ca63-4c03-b14a-f5b4eca67fce \
-drive file=/home/kvm_autotest_root/images/rhel77-64-virtio-scsi.qcow2,format=qcow2,if=none,id=drive-1,serial=drive-1,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0x6,drive=drive-1,id=disk1,bootindex=1,write-cache=on \
\
-drive file=/home/kvm_autotest_root/images/data1.raw,format=raw,if=none,id=drive-data1,serial=data1,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xe,drive=drive-data1,id=data1,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data2.raw,format=raw,if=none,id=drive-data2,serial=data2,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0x7,drive=drive-data2,id=data2,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data3.raw,format=raw,if=none,id=drive-data3,serial=data3,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0x9,drive=drive-data3,id=data3,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data4.raw,format=raw,if=none,id=drive-data4,serial=data4,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xa,drive=drive-data4,id=data4,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data5.raw,format=raw,if=none,id=drive-data5,serial=data5,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xb,drive=drive-data5,id=data5,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data6.raw,format=raw,if=none,id=drive-data6,serial=data6,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xc,drive=drive-data6,id=data6,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data7.raw,format=raw,if=none,id=drive-data7,serial=data7,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xd,drive=drive-data7,id=data7,write-cache=on \
-drive file=/home/kvm_autotest_root/images/data8.raw,format=raw,if=none,id=drive-data8,serial=data8,werror=stop,rerror=stop,cache=none,aio=native \
-device virtio-blk-pci,iothread=iothread1,scsi=off,bus=pci.0,addr=0xf,drive=drive-data8,id=data8,write-cache=on \
\
-device virtio-net-pci,mac=fa:f7:f8:5f:fa:5b,id=idn0VnaA,vectors=4,netdev=id8xJhp7,bus=pci.0 \
-netdev tap,id=id8xJhp7,vhost=on \
\
-device qxl-vga,id=ua-e20d399f-0dec-4dd6-a96f-e2d6245698ef,ram_size=67108864,vram_size=33554432,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pci.0 \
-object rng-random,id=objua-8dd7cf36-22a6-49bf-8552-fc8769ee1e7e,filename=/dev/urandom \
-device virtio-rng-pci,rng=objua-8dd7cf36-22a6-49bf-8552-fc8769ee1e7e,id=ua-8dd7cf36-22a6-49bf-8552-fc8769ee1e7e,bus=pci.0,addr=0x8 \
-device vmcoreinfo \
-vnc :6 \
        -rtc base=localtime,clock=host,driftfix=slew \
        -enable-kvm \
        -qmp tcp:0:5956,server,nowait \
        -monitor stdio \


old(){
echo
#/usr/libexec/qemu-kvm \
#        -name 'avocado-vt-vm1' \
#        -machine q35 \
#        -nodefaults \
#        -device VGA,bus=pcie.0,addr=0x1 \
#        -object iothread,id=iothread0 \
#        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel77-64-virtio-scsi.qcow2 \
#        -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
#        -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie.0-root-port-3,addr=0x0 \
#        -m 1G \
#        -smp 12,maxcpus=12,cores=6,threads=1,sockets=2 \
#       \
#        -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
#        -device virtio-net-pci,mac=9a:31:32:33:34:35,id=idYxHDLn,vectors=4,netdev=idoOknQC,bus=pcie.0-root-port-4,addr=0x0 \
#        -netdev tap,id=idoOknQC,vhost=on \
#        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
#        -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-5,addr=0x0 \
#        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
#        -device scsi-cd,id=cd1,drive=drive_cd1,bootindex=1 \
#        -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
#        -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
#        -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
#        -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
#        -device pcie-root-port,id=pcie_extra_root_port_1,slot=7,chassis=7,addr=0x7,bus=pcie.0 \
#        -device pcie-root-port,id=pcie_extra_root_port_2,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
#        -device pcie-root-port,id=pcie_extra_root_port_3,slot=9,chassis=9,addr=0x9,bus=pcie.0 \
#        -vnc :6 \
#        -rtc base=localtime,clock=host,driftfix=slew \
#        -enable-kvm \
#        -qmp tcp:0:5956,server,nowait \
#        -monitor stdio \


}

steps(){

# rhel820-64-virtio-scsi.qcow
{"execute": "qmp_capabilities"}
{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage0.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "bus": "pci.0"}, "id": "t07OBwF0"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg1,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage1.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg1", "drive": "drive_stg1", "bus": "pci.0"}, "id": "t07OBwF1"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg2,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage2.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg2", "drive": "drive_stg2", "bus": "pci.0"}, "id": "t07OBwF2"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg3,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage3.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg3", "drive": "drive_stg3", "bus": "pci.0"}, "id": "t07OBwF3"}


#q35
{"execute": "qmp_capabilities"}
{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage0.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "bus": "pcie_extra_root_port_0"}, "id": "t07OBwF0"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg1,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage1.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg1", "drive": "drive_stg1", "bus": "pcie_extra_root_port_1"}, "id": "t07OBwF1"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg2,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage2.raw"} }
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg2", "drive": "drive_stg2", "bus": "pcie_extra_root_port_2"}, "id": "t07OBwF2"}

D:\Iozone\iozone.exe -azR -r 64k -n 125M -g 512M -M -i 0 -i 1 -b E:\iozone_test -f E:\testfile

{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "XVosfhHr"}

#q35 should have two event,but only one event. pc looks like good
#for pc ok
    {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/storage0.qcow2"}, "id": "Yu6Mfcom"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "iothread": "iothread0", "bus": "pci.0", "addr": "0x8"}, "id": "0MFQJSVK"}

}

guest(){
  curl -Lk https://gitlab.cee.redhat.com/pingl/script_repo/raw/master/component_management.py -o /home/workdir/component_management.py
  curl -kL 'https://password.corp.redhat.com/RH-IT-Root-CA.crt' -o /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt
  curl -kL 'https://password.corp.redhat.com/legacy.crt' -o /etc/pki/ca-trust/source/anchors/legacy.crt
  curl -kL 'https://engineering.redhat.com/Eng-CA.crt' -o /etc/pki/ca-trust/source/anchors/Eng-CA.crt
  update-ca-trust enable
  update-ca-trust extract

  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-7-server.repo' -o /etc/yum.repos.d/rcm-tools-rhel-7.repo
  rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

 yum install nfs-utils stress-ng


stress-ng -m 1 --vm-bytes 200M --vm-keep
}