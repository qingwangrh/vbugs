#!/usr/bin/env bash

#default
os=rhel820
fmt=qcow2
drv=scsi
mode=blockdev

while getopts ":o:m:d:f:h" opt
do
    case $opt in
        h) echo "usage: -o <rhel820/win2019> -d <scsi/blk> -f<qcow2/raw>"
        exit 0
        ;;
        o) echo " $OPTARG"
        os="$OPTARG"
        ;;
        m) echo " $OPTARG"
        if [[ "$OPTARG" == "drive" ]]; then
            mode="drive"
        else
            mode="blockdev"
        fi
        ;;

        d) echo " $OPTARG"
        if [[ "$OPTARG" == "blk" ]]; then
            drv="blk"
        else
            drv="scsi"
        fi
        ;;
        f) echo " fmt= $OPTARG"
        if [[ "$OPTARG" == "raw" ]]; then
            fmt="raw"
        else
            fmt="qcow2"
        fi
        ;;
        ?) echo "unknown parameter"
        exit 1 ;;
    esac
done


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
    os_device="-device virtio-blk-pci,id=os_disk,drive=drive_image1,bus=pcie.0-root-port-2,addr=0x0,bootindex=0  "
    data_device=" -device virtio-blk-pci,id=data_disk,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1  "
else
    os_device="-device scsi-hd,id=os_disk,drive=drive_image1,bootindex=0  "
    data_device="-device scsi-hd,id=data_disk,drive=data_image1,bootindex=1  "
fi

echo ""
echo "${os_img}"
echo "${os_device}"
echo ""

/usr/libexec/qemu-kvm  \
 -name testvm  \
 -machine q35  \
 -nodefaults  \
 -vga qxl  \
 -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso  \
 -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0  \
 -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0  \
 -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0  \
 -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0  \
 -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0  \
 -device virtio-scsi-pci,id=scsi0,bus=pcie.0-root-port-5  \
 ${os_img}  \
 ${os_device}  \
 ${data_img}  \
 ${data_device}  \
 -vnc :7  \
 -monitor stdio  \
 -m 8192  \
 -smp 8  \
 -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0  \
 -device virtio-net-pci,mac=9a:b5:b6:b1:b2:b7,id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
 -netdev tap,id=idxgXAlm  \
 -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp7.log,server,nowait  \
 -mon chardev=qmp_id_qmpmonitor1,mode=control  \
 -qmp tcp:0:5957,server,nowait  \
 -chardev file,path=/var/tmp/monitor-serial7.log,id=serial_id_serial0  \
 -device isa-serial,chardev=serial_id_serial0  \
 -D debug.log \

