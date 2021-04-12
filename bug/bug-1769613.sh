#Test point:scsi+

#qemu-img create -f qcow2 /home/kvm_autotest_root/images/data0.qcow2 1G

source common.sh

common_env() {
  echo "common_env $@"
  if [[ "x$1" == "x" ]]; then
    idx=0
  else
    idx=$1
  fi
  os_img="rhel840-${idx}.qcow2"

  if [[ "x$2" == "x" ]]; then
    os_img="rhel840-${idx}.qcow2"
  else
    os_img=$2
  fi

  MAC="9a:b5:b6:b1:b2:b${idx}"
  port="595${idx}"
  vnc="1${idx}"
  data1_img="data${idx}-1.qcow2"
  data2_img="data${idx}-2.qcow2"
  data3_img="data${idx}-3.qcow2"
  img_dir=/home/kvm_autotest_root/images
  iso_dir=/home/kvm_autotest_root/iso
  [ -d ${iso_dir} ] || mkdir -p ${iso_dir}

  if ! mount | grep ${iso_dir}; then
    mount 10.73.194.27:/vol/s2kvmauto/iso ${iso_dir}
  fi
  [ -f ${img_dir}/${data1_img} ] || qemu-img create -f qcow2 ${img_dir}/${data1_img} 1G
  [ -f ${img_dir}/${data2_img} ] || qemu-img create -f qcow2 ${img_dir}/${data2_img} 2G
  [ -f ${img_dir}/${data3_img} ] || qemu-img create -f qcow2 ${img_dir}/${data3_img} 3G
}
env_print() {
  echo "${idx}"
  echo "${os_img}"
  echo "${img_dir}"
}
common_env "$@"
env_print
#iommu="iommu_platform=off,"
#iommu=""
iommu="iommu_platform=on,"

/usr/libexec/qemu-kvm \
-M q35,kernel-irqchip=split \
-m 4G \
-smp 4 \
-rtc base=localtime,driftfix=slew \
-device intel-iommu,device-iotlb=on,intremap \
-device pcie-root-port,id=pcie.0-root-port-3,slot=3,bus=pcie.0 \
-device pcie-root-port,id=pcie.0-root-port-4,slot=4,bus=pcie.0 \
\
-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=/home/kvm_autotest_root/images/rhel820-0.qcow2,node-name=drive_image1 \
-device virtio-scsi-pci,disable-legacy=on,disable-modern=off,${iommu}ats=on,id=scsi0,bus=pcie.0 \
-device scsi-hd,bus=scsi0.0,drive=drive_image1,id=virtio-disk0,bootindex=1 \
-drive file=/home/kvm_autotest_root/images/data0.qcow2,format=qcow2,if=none,id=drive-virtio-disk0 \
-device virtio-blk-pci,iommu_platform=on,bus=pcie.0-root-port-4,drive=drive-virtio-disk0,id=virtio-disk1,bootindex=2 \
\
-device piix3-usb-uhci,id=usb \
-device usb-tablet,id=tablet0 \
-vnc :5 \
-k en-us \
-qmp tcp:0:5955,server,nowait \
-boot menu=on \
-monitor stdio \
-device virtio-net-pci,mac=fa:f7:f8:5f:fa:5b,id=idn0VnaA,vectors=4,netdev=id8xJhp7,bus=pcie.0,addr=06 \
-netdev tap,id=id8xJhp7,vhost=on \


#-device intel-iommu,device-iotlb=on,intremap \
#-device virtio-blk-pci,iommu_platform=on,bus=pcie.0-root-port-3,drive=drive_image1,id=virtio-disk0,bootindex=1 \

#-device virtio-scsi-pci,disable-legacy=on,disable-modern=off,${iommu}ats=on,id=scsi0,bus=pcie.0 \
#-device scsi-hd,bus=scsi0.0,drive=drive_image1,id=virtio-disk0,bootindex=1 \
ovmf(){
  /usr/libexec/qemu-kvm \
        -name guest=sev_guest,debug-threads=on \
        -machine pc-q35-rhel7.6.0,accel=kvm,usb=off,vmport=off,smm=on,dump-guest-core=off \
        -global driver=cfi.pflash01,property=secure,value=on \
        -drive file=/usr/share/OVMF/OVMF_CODE.secboot.fd,if=pflash,format=raw,unit=0,readonly=on \
        -drive file=/var/lib/libvirt/qemu/nvram/sev_guest_VARS.fd,if=pflash,format=raw,unit=1 \
        -m 8192 \
        -realtime mlock=off \
        -smp 2,sockets=1,cores=2,threads=1 \
        -uuid 59922985-da31-4871-a4c3-535797d8b43a \
        -no-user-config \
        -nodefaults \
        -rtc base=utc,driftfix=slew \
        -global kvm-pit.lost_tick_policy=delay \
        -no-hpet \
        -no-shutdown \
        -global ICH9-LPC.disable_s3=1 \
        -global ICH9-LPC.disable_s4=1 \
        -boot strict=on \
        -device pcie-root-port,port=0x10,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2 \
        -device pcie-root-port,port=0x11,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1 \
        -device pcie-root-port,port=0x12,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2 \
        -device pcie-root-port,port=0x13,chassis=4,id=pci.4,bus=pcie.0,addr=0x2.0x3 \
        -device pcie-root-port,port=0x14,chassis=5,id=pci.5,bus=pcie.0,addr=0x2.0x4 \
        -device pcie-root-port,port=0x15,chassis=6,id=pci.6,bus=pcie.0,addr=0x2.0x5 \
        -device pcie-root-port,port=0x16,chassis=7,id=pci.7,bus=pcie.0,addr=0x2.0x6 \
        -device pcie-root-port,port=0x17,chassis=8,id=pci.8,bus=pcie.0,addr=0x2.0x7 \
        -device pcie-root-port,port=0x18,chassis=9,id=pci.9,bus=pcie.0,addr=0x3 \
        -device qemu-xhci,p2=15,p3=15,id=usb,bus=pci.3,addr=0x0 \
        -device virtio-scsi-pci,iommu_platform=on,id=scsi0,bus=pci.2,addr=0x0 \
        -drive file=/home/kvm_autotest_root/images/rhel820-64-virtio-scsi.ovmf.qcow2,format=qcow2,if=none,id=drive-scsi0-0-0-0 \
        -device scsi-hd,bus=scsi0.0,channel=0,scsi-id=0,lun=0,drive=drive-scsi0-0-0-0,id=scsi0-0-0-0,bootindex=1 \
        -drive file=/home/kvm_autotest_root/images/data0.qcow2,format=qcow2,if=none,id=drive-virtio-disk0 \
        -device virtio-blk-pci,scsi=off,iommu_platform=on,bus=pci.9,addr=0x0,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=2 \
\
        -device virtio-tablet-pci,id=input0,bus=pci.7,addr=0x0,iommu_platform=on \
        -device virtio-keyboard-pci,id=input1,bus=pci.8,addr=0x0,iommu_platform=on \
        \
        -spice port=5900,addr=0.0.0.0,disable-ticketing,image-compression=off,seamless-migration=on \
        -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pcie.0,addr=0x1 \
        -monitor stdio \
        -chardev socket,nowait,server,path=/var/tmp/serial-serial0-20191127-033824-iWPSNrYP,id=chardev_serial0 \
        -device isa-serial,id=serial0,chardev=chardev_serial0  \
\
        -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:56:00:00:00:02 \
        -netdev tap,id=hostnet0,vhost=on \

}
#-drive file=${img_dir}/${os_img},if=none,format=qcow2,cache=none,werror=stop,rerror=stop,id=drive_image1,aio=native \
#-blockdev driver=qcow2,file.driver=file,cache.direct=off,cache.no-flush=on,file.filename=${img_dir}/${os_img},node-name=drive_image1 \
