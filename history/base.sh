
os_img=rhel820.qcow2

idx=0
MAC="9a:b5:b6:b1:b2:b${idx}"
port="595${idx}"
vnc="${idx}"
data_img="data${idx}.qcow2"
img_dir=/home/kvm_autotest_root/images
iso_dir=/home/kvm_autotest_root/iso
[ -d ${iso_dir} ] || mkdir -p ${iso_dir}

if ! mount|grep ${iso_dir};then
mount 10.73.194.27:/vol/s2kvmauto/iso  ${iso_dir}
fi
[ -f ${img_dir}/${data_img} ] || qemu-img create -f qcow2 ${img_dir}/${data_img} 3G

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
        -drive id=drive_image1,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${os_img} \
        -device virtio-blk-pci,id=virtio_blk_pci1,drive=drive_image1,bus=pcie.0-root-port-2,addr=0x0,bootindex=0 \
        -drive id=drive_image2,if=none,snapshot=off,aio=threads,cache=none,format=qcow2,file=${img_dir}/${data_img} \
        -device virtio-blk-pci,id=virtio_blk_pci2,drive=drive_image2,bus=pcie.0-root-port-3,addr=0x0,bootindex=1 \
        -vnc :${vnc} \
        -monitor stdio \
        -m 8192 \
        -smp 8 \
        -device pcie-root-port,id=pcie.0-root-port-8,slot=8,chassis=8,addr=0x8,bus=pcie.0 \
        -device virtio-net-pci,mac=${MAC},id=idMmq1jH,vectors=4,netdev=idxgXAlm,bus=pcie.0-root-port-8,addr=0x0  \
        -netdev tap,id=idxgXAlm \
        -chardev file,id=qmp_id_qmpmonitor1,path=/var/tmp/monitor-qmp${idx}.log,server,nowait \
        -mon chardev=qmp_id_qmpmonitor1,mode=control  \
        -qmp tcp:localhost:${port},server,nowait  \
        -chardev file,path=/var/tmp/monitor-serial${idx}.log,id=serial_id_serial0 \
        -device isa-serial,chardev=serial_id_serial0  \
