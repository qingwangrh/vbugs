
blockdev(){

 /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -blockdev node-name=file_image1,driver=file,aio=threads,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:6a:8c:f2:9b:36,id=idQR5ite,netdev=idnHJ4ae,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idnHJ4ae,vhost=on \
    -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0  \
    -vnc :0  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5 \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5956,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \

}

drive(){


  /usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine q35 \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pcie.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,bus=pcie-root-port-2,addr=0x0 \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
    -device virtio-net-pci,mac=9a:21:f7:4a:1e:bc,id=idRuZxfv,netdev=idOpPVAe,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idOpPVAe,vhost=on \
    -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=none,media=cdrom,file=/home/kvm_autotest_root/iso/windows/winutils.iso \
    -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,bus=ide.0,unit=0  \
    -vnc :6  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,slot=5,chassis=5,addr=0x5,bus=pcie.0 \
    -device pcie-root-port,id=pcie_extra_root_port_1,slot=6,chassis=6,addr=0x6,bus=pcie.0 \
    \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5956,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \

}

steps(){
#guest application will hang when try to access disk.
#failed on wmvic diskdrive get index 
echo
qemu-img create -f raw /home/kvm_autotest_root/images/storage0.raw 1G


#blockdev
  {"execute": "qmp_capabilities", "id": "hfNLVWDt"}

 {"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "threads", "filename": "/home/kvm_autotest_root/images/storage0.raw", "cache": {"direct": true, "no-flush": false}}, "id": "SS8YgALa"}
 {"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "raw", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}, "id": "LAqjDMOz"}
 {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pcie_extra_root_port_0", "addr": "0x0"}, "id": "3vLbr6s2"}

 {"execute": "device_del", "arguments": {"id": "stg0"}, "id": "fIM0D6uN"}

 #event may present pair
  {"timestamp": {"seconds": 1588816929, "microseconds": 294261}, "event": "DEVICE_DELETED", "data": {"path": "/machine/peripheral/stg0/virtio-backend"}}
  {"timestamp": {"seconds": 1588816929, "microseconds": 348451}, "event": "DEVICE_DELETED", "data": {"device": "stg0", "path": "/machine/peripheral/stg0"}}

 {"execute": "blockdev-del", "arguments": {"node-name": "drive_stg0"}, "id": "fxcszsLh"}
 {"execute": "blockdev-del", "arguments": {"node-name": "file_stg0"}, "id": "KfvPl4II"}

#drive

 {"execute": "qmp_capabilities", "id": "hfNLVWDt"}

 {"execute": "human-monitor-command", "arguments": {"command-line": "drive_add auto id=drive_stg0,if=none,snapshot=off,aio=threads,cache=none,format=raw,file=/home/kvm_autotest_root/images/storage0.raw"}, "id": "dTzEMILD"}
 {"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "bus": "pcie_extra_root_port_0", "addr": "0x0"}, "id": "Gd6HrgqQ"}

 {"execute": "device_del", "arguments": {"id": "stg0"}, "id": "fIM0D6uN"}



}

#drive
blockdev
