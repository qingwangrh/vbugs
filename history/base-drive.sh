

if [[ "x$1"=="x" ]]; then
  idx=0
else
  idx=$1
fi

os_img="rhel820-${idx}.qcow2"
MAC="9a:b5:b6:b1:b2:b${idx}"
port="595${idx}"
vnc="1${idx}"
data1_img="data${idx}-1.qcow2"
data2_img="data${idx}-2.qcow2"
img_dir=/home/kvm_autotest_root/images
iso_dir=/home/kvm_autotest_root/iso
[ -d ${iso_dir} ] || mkdir -p ${iso_dir}

if ! mount | grep ${iso_dir}; then
  mount 10.73.194.27:/vol/s2kvmauto/iso ${iso_dir}
fi
[ -f ${img_dir}/${data1_img} ] || qemu-img create -f qcow2 ${img_dir}/${data1_img} 1G
[ -f ${img_dir}/${data2_img} ] || qemu-img create -f qcow2 ${img_dir}/${data2_img} 2G

/usr/libexec/qemu-kvm \
        -name ${os_img} \
        -machine q35 \
        -nodefaults \
        -vga qxl \
        -drive id=drive_cd1,if=none,snapshot=off,aio=threads,cache=unsafe,media=cdrom,file=/home/kvm_autotest_root/iso/linux/RHEL-7.7-20190723.1-Server-x86_64-dvd1.iso \
        -device ide-cd,id=cd1,drive=drive_cd1,bus=ide.0,unit=0 \
        -device pcie-root-port,id=pcie.0-root-port-2,slot=2,bus=pcie.0 \
        -device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
        -device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
        -device pcie-root-port,id=pcie.0-root-port-5,slot=5,bus=pcie.0 \
        -device virtio-scsi-pci,id=scsi0 \
        -device virtio-scsi-pci,id=scsi1,bus=pcie.0-root-port-5 \
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${os_img} \
        -device virtio-blk-pci,id=os1,drive=drive_image1,bus=pcie.0-root-port-2,addr=0x0,bootindex=0 \
        -drive id=data_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${data1_img} \
        -device virtio-blk-pci,id=data1,drive=data_image1,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
        -drive id=data_image2,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${data2_img} \
        -device scsi-hd,id=data2,drive=data_image2,bootindex=2 \
        -vnc :${vnc} \
        -monitor stdio \
        -m 8192 \
        -smp 8 \
        -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
        -device virtio-net-pci,mac=${MAC},id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
        -netdev tap,id=idxgXAlm \
        -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp${idx}.log,server,nowait \
        -mon chardev=qmp_id_qmpmonitor1,mode=control  \
        -qmp tcp:0:${port},server,nowait  \
        -chardev file,path=/var/tmp/monitor-serial${idx}.log,id=serial_id_serial0 \
        -device isa-serial,chardev=serial_id_serial0  \
