#!/usr/bin/env bash

#Default
os=rhel840
fmt=qcow2
drv=scsi
mode=blockdev
mac=9a:b5:b6:b1:b2:b7
params=
machine=q35
install=0
while getopts ":o:m:b:p:d:f:rhi" opt; do
  case $opt in
  h)
    echo -e "Usage: -o <rhel820/win2019> -b <scsi/blk> -f <qcow2/raw>
    -d <drive/blockdev> -m <q35/pc> -p <params> -i [enable installation]"
    exit 0
    ;;
  i)
    echo -e "Enable install"
    install=1
    ;;
  p)
    echo " $OPTARG"
    params="$OPTARG"
    ;;
  r)
    echo "using random mac address"
    mac=9a:b5:b6:b1:b2:$(($RANDOM % 99))
    ;;
  o)
    echo " $OPTARG"
    os="$OPTARG"
    ;;
  m)
    echo "machine $OPTARG"
    if [[ "$OPTARG" == "pc" ]]; then
      machine="pc"
    else
      machine="q35"
    fi
    ;;
  d)
    echo " $OPTARG"
    if [[ "$OPTARG" == "drive" ]]; then
      mode="drive"
    else
      mode="blockdev"
    fi
    ;;
  b)
    echo " $OPTARG"
    if [[ "$OPTARG" == "blk" ]]; then
      drv="blk"
    else
      drv="scsi"
    fi
    ;;
  f)
    echo " fmt= $OPTARG"
    if [[ "$OPTARG" == "raw" ]]; then
      fmt="raw"
    else
      fmt="qcow2"
    fi
    ;;
  ?)
    echo "unknown parameter"
    exit 1
    ;;
  esac
done

[ "x$params" != "x" ] && params=",$params"

data_img_name="data1.qcow2"
img_dir=/home/kvm_autotest_root/images
iso_dir=/home/kvm_autotest_root/iso

[ -d ${iso_dir} ] || mkdir -p ${iso_dir}

if ! mount | grep ${iso_dir}; then
  mount 10.73.194.27:/vol/s2kvmauto/iso ${iso_dir}
fi

[[ -f ${img_dir}/${data_img_name} ]] || qemu-img create -f qcow2 ${img_dir}/${data_img_name} 3G

if [[ "$machine" == "pc" ]]; then
  bus="pci.0"
else
  bus="pcie.0"
fi

if [[ "$install" == "1" ]]; then
  os="${os}-new"
fi

if [[ "$drv" == "blk" ]]; then
  os_img_name="${os}-64-virtio.${fmt}"
else
  os_img_name="${os}-64-virtio-scsi.${fmt}"
fi

if [[ ! -e ${img_dir}/${os_img_name} ]]; then
  echo "Can not find os image ${img_dir}/${os_img_name}"
  exit 1
  echo "Create install disk"
  qemu-img create -f ${fmt} ${img_dir}/${os_img_name} 25G
fi

if [[ "$mode" == "drive" ]]; then
  os_img="-drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=${fmt},file=${img_dir}/${os_img_name}  "
  data_img="-drive id=data_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${data_img_name}  "
else
  os_img="-blockdev driver=${fmt},file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${os_img_name},node-name=drive_image1  "
  data_img="-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${data_img_name},node-name=data_image1  "
fi

if [[ "$drv" == "blk" ]]; then
  os_device="-device virtio-blk-pci,id=os,drive=drive_image1,bus=pcie-root-port-2,addr=0x0,bootindex=0,serial=OS_DISK  "
  data_device="-device virtio-blk-pci,id=data1,drive=data_image1,bus=pcie-root-port-3,addr=0x0,bootindex=1${params},serial=DATA_DISK  "
else
  os_device="-device scsi-hd,id=os,drive=drive_image1,bus=scsi0.0,bootindex=0,serial=OS_DISK  "
  data_device="-device scsi-hd,id=data1,drive=data_image1,bus=scsi0.0,bootindex=1${params},serial=DATA_DISK,scsi-id=64  "
fi

echo "${params}"
echo "${os_img}"
echo "${os_device}"
echo "${data_device}"
echo "${mac}"
echo ""

if echo "${os}" | grep rhel; then
  os_iso=$(readlink /home/kvm_autotest_root/iso/linux/RHEL8.4.0-BaseOS-x86_64.iso -f)
  cds=" @
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=${os_iso},cache.direct=on,cache.no-flush=off @
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 @
  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=scsi1.0 @"
else
  os_iso=$(readlink /home/kvm_autotest_root/iso/ISO/Win2019/latest_x86_64/* -f)
  cds=" @
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=${os_iso},cache.direct=on,cache.no-flush=off @
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 @
  -device scsi-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=scsi1.0 @
  -blockdev node-name=file_cd2,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso,cache.direct=on,cache.no-flush=off @
  -blockdev node-name=drive_cd2,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd2 @
  -device scsi-cd,id=cd2,drive=drive_cd2,write-cache=on,bus=scsi1.0 @
  -blockdev node-name=file_cd3,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off @
  -blockdev node-name=drive_cd3,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd3 @
  -device scsi-cd,id=cd3,drive=drive_cd3,write-cache=on,bus=scsi1.0 @"
fi

  #-cpu 'Skylake-Server',+kvm_pv_unhalt @
  #-cpu host @
  #-cpu 'EPYC-Rome',+kvm_pv_unhalt @
  #-nodefaults @
  #-device VGA @
cmd="
/usr/libexec/qemu-kvm @
  -name testvm @
  -machine ${machine} @
  -cpu host,+kvm_pv_unhalt @
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=${bus},addr=0x3,chassis=1 @
  -device pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x3.0x1,bus=${bus},chassis=2 @
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x3.0x2,bus=${bus},chassis=3 @
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x3.0x3,bus=${bus},chassis=4 @
  -device pcie-root-port,id=pcie-root-port-4,port=0x4,addr=0x3.0x4,bus=${bus},chassis=5 @
  -device pcie-root-port,id=pcie-root-port-5,port=0x5,addr=0x3.0x5,bus=${bus},chassis=6 @
  -device pcie-root-port,id=pcie-root-port-6,port=0x6,addr=0x3.0x6,bus=${bus},chassis=7 @
  -device pcie-root-port,id=pcie-root-port-7,port=0x7,addr=0x3.0x7,bus=${bus},chassis=8 @
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 @
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 @
  -device virtio-scsi-pci,id=scsi0,bus=pcie-root-port-5 @
  -device virtio-scsi-pci,id=scsi1,bus=pcie-root-port-6 @
  ${os_img} @
  ${os_device} @
  ${data_img} @
  ${data_device} @
  -vnc :5 @
  -monitor stdio @
  -m 8G @
  -smp 8 @
  -device pcie-root-port,id=pcie-root-port-8,slot=8,chassis=8,addr=0x8,bus=${bus} @
  -device virtio-net-pci,mac=${mac},id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie-root-port-8,addr=0x0 @
  -netdev tap,id=idxgXAlm @
  -chardev socket,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp7.log,server,nowait @
  -mon chardev=qmp_id_qmpmonitor1,mode=control @
  -qmp tcp:0:5955,server,nowait @
  -chardev file,path=/var/tmp/monitor-serial7.log,id=serial_id_serial0 @
  -device isa-serial,chardev=serial_id_serial0 @
  -D debug.log @
  -boot menu=on,reboot-timeout=1000 @
  ${cds}

"

cmd="${cmd//@/\\}"
echo -e "$cmd"
eval "$cmd"

steps() {

  #floppy
  -drive file=fda.img,if=none,id=drive-fdc0-0-0,format=raw @
  -device floppy,unit=0,drive=drive-fdc0-0-0 @

  -blockdev driver=file,filename=/home/kvm_autotest_root/images/fda.img,node-name=libvirt-1-storage @
  -blockdev node-name=libvirt-1-format,read-only=off,driver=raw,file=libvirt-1-storage @
  -device floppy,unit=0,drive=libvirt-1-format,id=fdc0-0-0 @

}
