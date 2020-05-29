[[ -f /home/kvm_autotest_root/images/stg0.qcow2 ]] || qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G

/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x2 \
    -m 8096  \
    -smp 12,maxcpus=12,cores=6,threads=1,dies=1,sockets=2  \
    -cpu 'Skylake-Server',+kvm_pv_unhalt \
    -device qemu-xhci,id=usb1,bus=pci.0,addr=0x3 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread0 \
    -object iothread,id=iothread1 \
    -blockdev node-name=file_image1,driver=file,aio=native,filename=/home/kvm_autotest_root/images/win2019-64-virtio.qcow2,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=qcow2,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,bus=pci.0,addr=0x4,iothread=iothread0 \
    -device virtio-net-pci,mac=9a:5b:a6:38:4a:e0,id=idyjQtQD,netdev=id00H6DM,bus=pci.0,addr=0x5  \
    -netdev tap,id=id00H6DM,vhost=on \
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


steps(){

qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg0.qcow2 1G



#qmp

{"execute":"qmp_capabilities"}

{"execute": "stop", "id": "1oeqHhY5"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/stg0.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "2phsVuDb"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}, "id": "M0L7Dev7"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pci.0", "addr": "0x6", "iothread": "iothread1"}, "id": "QbpsYOwH"}

#check in guest
 {"execute": "cont", "id": "QbpDso2b"}
#check in guest

{"execute": "stop", "id": "ovtzmD4f"}


{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "D6xK2PmP"}
#check
{"execute": "human-monitor-command", "arguments": {"command-line": "info qtree"}, "id": "p3DXJ97J"}

#still in qtree.
{"execute": "cont", "id": "QbpDso2b"}

#it will disappear
{"execute": "human-monitor-command", "arguments": {"command-line": "info qtree"}, "id": "p3DXJ97J"}

http://10.66.8.105:8000/%5B8.2.1%5D-2-PC%2BSeabios%2B8.3%2BQcow2%2BVirtio_blk%2BLocal%2Baio_native/test-results/131-Host_RHEL.m8.u2.product_av.qcow2.virtio_blk.up.virtio_net.Guest.RHEL.8.3.0.x86_64.io-github-autotest-qemu.block_hotplug_in_pause.with_plug.one_pci/

#case 2 not work for windows
{"execute":"qmp_capabilities"}

{"execute": "stop", "id": "1oeqHhY5"}

{"execute": "blockdev-add", "arguments": {"node-name": "file_stg0", "driver": "file", "aio": "native", "filename": "/home/kvm_autotest_root/images/stg0.qcow2", "cache": {"direct": true, "no-flush": false}}, "id": "2phsVuDb"}
{"execute": "blockdev-add", "arguments": {"node-name": "drive_stg0", "driver": "qcow2", "cache": {"direct": true, "no-flush": false}, "file": "file_stg0"}, "id": "M0L7Dev7"}
{"execute": "device_add", "arguments": {"driver": "virtio-blk-pci", "id": "stg0", "drive": "drive_stg0", "write-cache": "on", "bus": "pci.0", "addr": "0x6", "iothread": "iothread1"}, "id": "QbpsYOwH"}

{"execute": "cont", "id": "QbpDso2b"}
{"execute": "stop", "id": "1oeqHhY5"}
{"execute": "device_del", "arguments": {"id": "stg0"}, "id": "D6xK2PmP"}

{"execute": "cont", "id": "QbpDso2b"}

}