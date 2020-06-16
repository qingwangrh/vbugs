#Bug 1706759 - qemu core dump when unplug a 16T GPT type disk from win2019 guest
# https://polarion.engineering.redhat.com/polarion/#/project/RedHatEnterpriseLinux7/workitem?id=RHEL-144360
#block_hotplug.block_virtio.fmt_qcow2.max_size.with_plug.one_pci

ovmf() {
/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=idZcGD6F  \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-ovmf-virtio.qcow2 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie.0-root-port-3,addr=0x0 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0,addr=0x4 \
    -device pcie-root-port,id=pcie.0-root-port-5,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:55:56:57:58:59,id=id18Xcuo,netdev=idGRsMas,bus=pcie.0-root-port-5,addr=0x0  \
    -netdev tap,id=idGRsMas,vhost=on \
    -m 13312  \
    -smp 24,maxcpus=24,cores=12,threads=1,sockets=2  \
    -cpu 'Skylake-Server',hv_stimer,hv_synic,hv_vpindex,hv_reset,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time,hv-tlbflush,+kvm_pv_unhalt \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/ISO/Win2019/en_windows_server_2019_updated_march_2019_x64_dvd_2ae967ab.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,bus=ide.0,unit=0 \
    -drive id=drive_virtio,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-172.iso \
    -device ide-cd,id=virtio,drive=drive_virtio,bootindex=3,bus=ide.1,unit=0 \
    -drive id=drive_winutils,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=winutils,drive=drive_winutils,bus=ide.2,unit=0\
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.secboot.fd \
    -drive if=pflash,format=raw,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2.fd \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}
scsi_hd(){

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1' \
    -machine q35  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x1  \
    -device pvpanic,ioport=0x505,id=id5iZYDr \
    -device pcie-root-port,id=pcie.0-root-port-2,slot=2,chassis=2,addr=0x2,bus=pcie.0 \
    -device qemu-xhci,id=usb1,bus=pcie.0-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie.0-root-port-3,slot=3,chassis=3,addr=0x3,bus=pcie.0 \
    -device virtio-scsi-pci,id=virtio_scsi_pci0,bus=pcie.0-root-port-3,addr=0x0 \
    -drive id=drive_image1,if=none,snapshot=off,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio-scsi.qcow2 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=0 \
    -device pcie-root-port,id=pcie.0-root-port-4,slot=4,chassis=4,addr=0x4,bus=pcie.0 \
    -device virtio-net-pci,mac=9a:82:31:9d:ee:b5,id=idqsUmFe,netdev=idq2XyuZ,bus=pcie.0-root-port-4,addr=0x0  \
    -netdev tap,id=idq2XyuZ,vhost=on \
    -m 10240  \
    -smp 12,maxcpus=12,cores=6,threads=1,sockets=2  \
    -drive id=drive_cd1,if=none,snapshot=off,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device scsi-cd,id=cd1,drive=drive_cd1 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1  \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -monitor stdio \
    -qmp tcp:0:5955,server,nowait \

}

#ovmf
scsi_hd


steps(){
cp /usr/share/edk2/ovmf/OVMF_VARS.fd  /home/kvm_autotest_root/images/win2019-64-virtio.qcow2.fd
qemu-img create -f qcow2 /home/kvm_autotest_root/images/data-16t.qcow2 16T

{"execute": "qmp_capabilities", "id": "ExmD8nws"}

{"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/data-16t.qcow2"}, "id": "5QU1d5ov"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "bus": "pcie_extra_root_port_0"}, "id": "oraTG8Ej"}


F:\coreutils\DummyCMD.ext g:\123 4096000000 1
D:\coreutils\DummyCMD.ext e:\123 4096000000 1

{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "ykdZ52t3"}

}