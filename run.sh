#!/usr/bin/env bash

#default
os=rhel830
fmt=qcow2
drv=scsi
mode=blockdev
mac=9a:b5:b6:b1:b2:b7
params=
while getopts ":o:m:p:d:f:rh" opt; do
  case $opt in
  h)
    echo "usage: -o <rhel820/win2019> -d <scsi/blk> -f<qcow2/raw> -m <drive/blockdev> -p <params>"
    exit 0
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
    echo " $OPTARG"
    if [[ "$OPTARG" == "drive" ]]; then
      mode="drive"
    else
      mode="blockdev"
    fi
    ;;
  d)
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

if [[ "$drv" == "blk" ]]; then
  os_img_name="${os}-64-virtio.${fmt}"
else
  os_img_name="${os}-64-virtio-scsi.${fmt}"
fi

if [[ "$mode" == "drive" ]]; then
  os_img="-drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=${fmt},file=${img_dir}/${os_img_name}  "
  data_img="-drive id=data_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${data_img_name}  "
else
  os_img="-blockdev driver=${fmt},file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${os_img_name},node-name=drive_image1  "
  data_img="-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${data_img_name},node-name=data_image1  "
fi

if [[ "$drv" == "blk" ]]; then
  os_device="-device virtio-blk-pci,id=os_disk,drive=drive_image1,bus=pcie.0-root-port-2,addr=0x0,bootindex=0,serial=OS_DISK  "
  data_device="-device virtio-blk-pci,id=data_disk,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1${params},serial=DATA_DISK  "
else
  os_device="-device scsi-hd,id=os_disk,drive=drive_image1,bootindex=0,serial=OS_DISK  "
  data_device="-device scsi-hd,id=data_disk,drive=data_image1,bootindex=1${params},serial=DATA_DISK  "
fi

echo "${params}"
echo "${os_img}"
echo "${os_device}"
echo "${data_device}"
echo "${mac}"
echo ""

winos_iso=$(readlink /home/kvm_autotest_root/iso/ISO/Win2019/latest_x86_64/* -f)

/usr/libexec/qemu-kvm \
  -name testvm \
  -machine q35 \
  -nodefaults \
  -vga qxl \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x2,chassis=1 \
  -device pcie-root-port,id=pcie.0-root-port-1,port=0x1,addr=0x2.0x1,bus=pcie.0,chassis=2 \
  -device pcie-root-port,id=pcie.0-root-port-2,port=0x2,addr=0x2.0x2,bus=pcie.0,chassis=3 \
  -device pcie-root-port,id=pcie.0-root-port-3,port=0x3,addr=0x2.0x3,bus=pcie.0,chassis=4 \
  -device pcie-root-port,id=pcie.0-root-port-4,port=0x4,addr=0x2.0x4,bus=pcie.0,chassis=5 \
  -device pcie-root-port,id=pcie.0-root-port-5,port=0x5,addr=0x2.0x5,bus=pcie.0,chassis=6 \
  -device pcie-root-port,id=pcie.0-root-port-6,port=0x6,addr=0x2.0x6,bus=pcie.0,chassis=7 \
  -device pcie-root-port,id=pcie.0-root-port-7,port=0x7,addr=0x2.0x7,bus=pcie.0,chassis=8 \
  -device qemu-xhci,id=usb1,bus=pcie.0-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-5 \
  ${os_img} \
  ${os_device} \
  ${data_img} \
  ${data_device} \
  -vnc :7 \
  -monitor stdio \
  -m 8192 \
  -smp 8 \
  -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
  -device virtio-net-pci,mac=${mac},id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0 \
  -netdev tap,id=idxgXAlm \
  -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp7.log,server,nowait \
  -mon chardev=qmp_id_qmpmonitor1,mode=control \
  -qmp tcp:0:5957,server,nowait \
  -chardev file,path=/var/tmp/monitor-serial7.log,id=serial_id_serial0 \
  -device isa-serial,chardev=serial_id_serial0 \
  -D debug.log \
  -blockdev node-name=file_cd1,driver=file,read-only=on,aio=threads,filename=${winos_iso},cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,write-cache=on,bus=ide.0,unit=0 \
  -blockdev node-name=file_cd2,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd2,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd2 \
  -device ide-cd,id=cd2,drive=drive_cd2,write-cache=on,bus=ide.1,unit=0 \
  -blockdev node-name=file_cd3,driver=file,read-only=on,aio=threads,filename=/home/kvm_autotest_root/iso/windows/winutils.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd3,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd3 \
  -device ide-cd,id=cd3,drive=drive_cd3,write-cache=on,bus=ide.2,unit=0 \


