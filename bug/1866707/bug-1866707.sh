#repeatly hotplug/unplug multi disks


/usr/libexec/qemu-kvm \
    -name 'avocado-vt-vm1'  \
    -sandbox on  \
    -machine pc \
    -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pci.0,addr=0x2,chassis=1 \
    -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0  \
    -nodefaults \
    -device VGA,bus=pci.0,addr=0x3 \
    -m 2048  \
    -smp 12,maxcpus=12,cores=6,threads=1,sockets=2  \
    -device pcie-root-port,id=pcie-root-port-1,bus=pci.0,chassis=2 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,bus=pci.0,chassis=3 \
    -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
    -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
    -object iothread,id=iothread1 \
    -device virtio-scsi,id=scsi0 \
    -device virtio-scsi,id=scsi1,iothread=iothread1 \
    -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.qcow2 \
    -device scsi-hd,id=image1,drive=drive_image1,bootindex=0,bus=scsi0.0 \
    \
    -blockdev node-name=test_disk0,driver=file,filename=/home/kvm_autotest_root/images/stg0.qcow2 \
    -device scsi-hd,drive=test_disk0,bus=scsi1.0,bootindex=-1,id=scsi_disk0,channel=0,scsi-id=0,channel=0,scsi-id=0,lun=0,share-rw \
    -blockdev node-name=test_disk1,driver=file,filename=/home/kvm_autotest_root/images/stg1.qcow2 \
    -blockdev node-name=test_disk2,driver=file,filename=/home/kvm_autotest_root/images/stg2.qcow2 \
    -blockdev node-name=test_disk3,driver=file,filename=/home/kvm_autotest_root/images/stg3.qcow2 \
    -blockdev node-name=test_disk4,driver=file,filename=/home/kvm_autotest_root/images/stg4.qcow2 \
    -blockdev node-name=test_disk5,driver=file,filename=/home/kvm_autotest_root/images/stg5.qcow2 \
    -blockdev node-name=test_disk6,driver=file,filename=/home/kvm_autotest_root/images/stg6.qcow2 \
    -blockdev node-name=test_disk7,driver=file,filename=/home/kvm_autotest_root/images/stg7.qcow2 \
    -blockdev node-name=test_disk8,driver=file,filename=/home/kvm_autotest_root/images/stg8.qcow2 \
    -blockdev node-name=test_disk9,driver=file,filename=/home/kvm_autotest_root/images/stg9.qcow2 \
    -blockdev node-name=test_disk10,driver=file,filename=/home/kvm_autotest_root/images/stg10.qcow2 \
    -blockdev node-name=test_disk11,driver=file,filename=/home/kvm_autotest_root/images/stg11.qcow2 \
    -blockdev node-name=test_disk12,driver=file,filename=/home/kvm_autotest_root/images/stg12.qcow2 \
    -blockdev node-name=test_disk13,driver=file,filename=/home/kvm_autotest_root/images/stg13.qcow2 \
    -blockdev node-name=test_disk14,driver=file,filename=/home/kvm_autotest_root/images/stg14.qcow2 \
    -blockdev node-name=test_disk15,driver=file,filename=/home/kvm_autotest_root/images/stg15.qcow2 \
    -blockdev node-name=test_disk16,driver=file,filename=/home/kvm_autotest_root/images/stg16.qcow2 \
    -blockdev node-name=test_disk17,driver=file,filename=/home/kvm_autotest_root/images/stg17.qcow2 \
    -blockdev node-name=test_disk18,driver=file,filename=/home/kvm_autotest_root/images/stg18.qcow2 \
    -blockdev node-name=test_disk19,driver=file,filename=/home/kvm_autotest_root/images/stg19.qcow2 \
    -blockdev node-name=test_disk20,driver=file,filename=/home/kvm_autotest_root/images/stg20.qcow2 \
    -blockdev node-name=test_disk21,driver=file,filename=/home/kvm_autotest_root/images/stg21.qcow2 \
    -blockdev node-name=test_disk22,driver=file,filename=/home/kvm_autotest_root/images/stg22.qcow2 \
    -blockdev node-name=test_disk23,driver=file,filename=/home/kvm_autotest_root/images/stg23.qcow2 \
    -blockdev node-name=test_disk24,driver=file,filename=/home/kvm_autotest_root/images/stg24.qcow2 \
    -blockdev node-name=test_disk25,driver=file,filename=/home/kvm_autotest_root/images/stg25.qcow2 \
    -blockdev node-name=test_disk26,driver=file,filename=/home/kvm_autotest_root/images/stg26.qcow2 \
    -blockdev node-name=test_disk27,driver=file,filename=/home/kvm_autotest_root/images/stg27.qcow2 \
    -blockdev node-name=test_disk28,driver=file,filename=/home/kvm_autotest_root/images/stg28.qcow2 \
    -blockdev node-name=test_disk29,driver=file,filename=/home/kvm_autotest_root/images/stg29.qcow2 \
    -blockdev node-name=test_disk30,driver=file,filename=/home/kvm_autotest_root/images/stg30.qcow2 \
    -blockdev node-name=test_disk31,driver=file,filename=/home/kvm_autotest_root/images/stg31.qcow2 \
    -blockdev node-name=test_disk32,driver=file,filename=/home/kvm_autotest_root/images/stg32.qcow2 \
    -blockdev node-name=test_disk33,driver=file,filename=/home/kvm_autotest_root/images/stg33.qcow2 \
    -blockdev node-name=test_disk34,driver=file,filename=/home/kvm_autotest_root/images/stg34.qcow2 \
    -blockdev node-name=test_disk35,driver=file,filename=/home/kvm_autotest_root/images/stg35.qcow2 \
    -blockdev node-name=test_disk36,driver=file,filename=/home/kvm_autotest_root/images/stg36.qcow2 \
    -blockdev node-name=test_disk37,driver=file,filename=/home/kvm_autotest_root/images/stg37.qcow2 \
    -blockdev node-name=test_disk38,driver=file,filename=/home/kvm_autotest_root/images/stg38.qcow2 \
    -blockdev node-name=test_disk39,driver=file,filename=/home/kvm_autotest_root/images/stg39.qcow2 \
    -blockdev node-name=test_disk40,driver=file,filename=/home/kvm_autotest_root/images/stg40.qcow2 \
    \
    -device pcie-root-port,id=pcie-root-port-3,port=0x3,bus=pci.0,chassis=4 \
    -device virtio-net-pci,mac=9a:21:f7:4a:1e:bd,id=idRuZxfv,netdev=idOpPVAe,bus=pcie-root-port-3,addr=0x0  \
    -netdev tap,id=idOpPVAe,vhost=on  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot menu=off,order=cdn,once=c,strict=off \
    -enable-kvm \
    -vnc :5  \
    -rtc base=localtime,clock=host,driftfix=slew  \
    -boot order=cdn,once=c,menu=off,strict=off \
    -enable-kvm \
    -device pcie-root-port,id=pcie_extra_root_port_0,bus=pci.0 \
    -monitor stdio \
    -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmpdbg.log,server,nowait \
    -mon chardev=qmp_id_qmpmonitor1,mode=control  \
    -qmp tcp:0:5955,server,nowait  \
    -chardev file,path=/var/tmp/monitor-serialdbg.log,id=serial_id_serial0 \
    -device isa-serial,chardev=serial_id_serial0  \

steps(){
  #test point iothread
  #not reproduce on libvirt
  #this related repeated hotplug/unplug

  wloop 0 41 qemu-img create -f qcow2 stg@@.qcow2 1G

# NUM_LUNS = 12 also may reproduce this issue
  NUM_LUNS=40
add_devices() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response
  for i in $(seq 1 $NUM_LUNS) ; do
  cmd="{'execute':'device_add', 'arguments': {'driver':'scsi-hd','drive':'test_disk$i','id':'scsi_disk$i','bus':'scsi1.0','lun':$i}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  done
}

remove_devices() {
  exec 3<>/dev/tcp/localhost/5955
  echo "$@"
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response
  for i in $(seq 1 $NUM_LUNS) ; do
  cmd="{'execute':'device_del', 'arguments': {'id':'scsi_disk$i'}}"
  echo "$cmd"
  echo -e "$cmd" >&3
  read response <&3
  echo "$response"
  done
}


while true ; do
    echo "adding devices"
    add_devices
    sleep 3
    echo "removing devices"
    remove_devices
    sleep 3
done
}