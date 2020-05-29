

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 7168  \
    -smp 8,maxcpus=8,cores=4,threads=1,sockets=2  \
    -cpu 'IvyBridge',+kvm_pv_unhalt \
    -device nec-usb-xhci,id=usb1,bus=pcie.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -drive id=drive_image1,if=none,snapshot=off,aio=native,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel830-64-virtio.qcow2 \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie-root-port-1,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-net-pci,mac=9a:36:13:b9:e8:ea,id=idr05pzH,netdev=idMWMi2H,bus=pcie-root-port-2,addr=0x0  \
    -netdev tap,id=idMWMi2H,vhost=on \
    -drive id=drive_none,if=none,snapshot=off,aio=native,media=cdrom \
    -device ide-cd,id=none,drive=drive_none,bootindex=1,bus=ide.0,unit=0  \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=native,filename=/tmp/orig.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=2,write-cache=on,bus=ide.1,unit=0  \
    -vnc :6  \
    -rtc base=utc,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5956,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x4,chassis=4 \




steps(){

#host
dd if=/dev/urandom of=/tmp/orig.dat bs=1M count=100
mkisofs -o /tmp/orig.iso /tmp/orig.dat
cp -rf /tmp/orig.iso /tmp/new.iso
cp -rf /tmp/orig.iso /tmp/new2.iso

#mkisofs -o /tmp/new.iso orig.iso
#mkisofs -o /tmp/new2.iso orig.iso

#qmp

{"execute":"qmp_capabilities"}

#drive
#Before change Removable device: not locked, tray closed
{"execute": "change", "arguments": {"device": "drive_none", "target": "/tmp/new.iso"}, "id": "aTQB54AY"}

#after change => Removable device: locked, tray closed
{"execute": "eject", "arguments": {"device": "drive_none", "force": false}, "id": "AoMUazFq"}

#will failed "Device 'drive_none' is locked and force was not specified, wait for tray to open and try again"
# it can be fixed set force -> true
{"execute": "eject", "arguments": {"device": "drive_none", "force": true}, "id": "AoMUazFq"}

#will success
{"execute": "change", "arguments": {"device": "drive_none", "target": "/tmp/new2.iso"}, "id": "aTQB54AY"}


#blockdev
{"execute":"blockdev-open-tray","arguments":{"id":"cd1"}}

{"execute":"blockdev-open-tray","arguments":{"id":"cd1","force": true}}

{"execute":"blockdev-remove-medium","arguments":{"id":"cd1"}}

{"execute": "query-block"}


#it will failed if locked before, so it do twice
{'execute': 'blockdev-change-medium', 'arguments': {'id': 'cd1', 'filename': '/tmp/new.iso'}}


 {'execute': 'blockdev-change-medium', 'arguments': {'id': 'cd1', 'filename': '/tmp/new2.iso'}}

https://polarion.engineering.redhat.com/polarion/#/project/RedHatEnterpriseLinux7/workitem?id=RHEL7-11952&form_mode=edit

}
