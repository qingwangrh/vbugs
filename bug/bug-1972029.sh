qemu-img create -f raw /home/scsi/win10.raw 30g

mac=9a:a6:6b:c2:93:56
if [[ "$1" != "" ]];then
  mac=9a:a6:6b:c2:93:5$1
fi

/usr/libexec/qemu-kvm \
  -name \
  'avocado-vt-vm1' \
  -sandbox on \
  -machine q35,memory-backend=mem-machine_mem \
  -device pcie-root-port,id=pcie-root-port-0,multifunction=on,bus=pcie.0,addr=0x1,chassis=1 \
  -device pcie-pci-bridge,id=pcie-pci-bridge-0,addr=0x0,bus=pcie-root-port-0 \
  -nodefaults \
  -device VGA,bus=pcie.0,addr=0x2 \
  -m 12288 \
  -object memory-backend-ram,size=12288M,id=mem-machine_mem \
  -smp 10,maxcpus=10,cores=5,threads=1,dies=1,sockets=2 \
  -cpu host \
  -device \
  pcie-root-port,id=pcie-root-port-1,port=0x1,addr=0x1.0x1,bus=pcie.0,chassis=2 \
  -device qemu-xhci,id=usb1,bus=pcie-root-port-1,addr=0x0 \
  -device usb-tablet,id=usb-tablet1,bus=usb1.0,port=1 \
  -object iothread,id=iothread0 \
  -object iothread,id=iothread1 \
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=native,filename=/home/scsi/win10.raw,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_image1,driver=raw,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
  -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3 \
  -device virtio-blk-pci,id=image1,drive=drive_image1,bootindex=0,write-cache=on,serial=SYSTEM_DISK0,bus=pcie-root-port-2,addr=0x0,iothread=iothread0 \
  -device pcie-root-port,id=pcie-root-port-3,port=0x3,addr=0x1.0x3,bus=pcie.0,chassis=4 \
  -device virtio-net-pci,mac=$mac,id=idd0M4NV,netdev=idtL9U8k,bus=pcie-root-port-3,addr=0x0 \
  -netdev tap,id=idtL9U8k,vhost=on \
  -blockdev node-name=file_cd1,driver=file,auto-read-only=on,discard=unmap,aio=native,filename=/home/kvm_autotest_root/iso/ISO/Win10/en_windows_10_business_editions_version_21h1_x64_dvd_ec5a76c1.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_cd1,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_cd1 \
  -device ide-cd,id=cd1,drive=drive_cd1,bootindex=1,write-cache=on,bus=ide.0,unit=0 \
  -blockdev node-name=file_unattended,driver=file,auto-read-only=on,discard=unmap,aio=native,filename=/home/kvm_autotest_root/iso/windows/virtio-win-prewhql-0.1-201.iso,cache.direct=on,cache.no-flush=off \
  -blockdev node-name=drive_unattended,driver=raw,read-only=on,cache.direct=on,cache.no-flush=off,file=file_unattended \
  -device ide-cd,id=unattended,drive=drive_unattended,bootindex=3,write-cache=on,bus=ide.2,unit=0 \
  -vnc :5 \
  -rtc base=localtime,clock=host,driftfix=slew \
  -boot menu=off,order=cdn,once=d,strict=off \
  -enable-kvm -monitor stdio \
  -device pcie-root-port,id=pcie_extra_root_port_0,multifunction=on,bus=pcie.0,addr=0x3,chassis=5

steps() {
  #this issue related to 4k disks
  #  Disk /dev/mapper/rhel_dell--per440--10-home: 455.5 GiB, 489093595136 bytes, 119407616 sectors
  #Units: sectors of 1 * 4096 = 4096 bytes
  #Sector size (logical/physical): 4096 bytes / 4096 bytes
  #I/O size (minimum/optimal): 4096 bytes / 4096 bytes

  automation:
  python ConfigTest.py --testcase=unattended_install.cdrom.extra_cdrom_ks.default_install.aio_threads --iothread_scheme=roundrobin --nr_iothreads=2 --platform=x86_64 --guestname=Win10 --driveformat=virtio_blk --nicmodel=virtio_net --imageformat=raw --machines=q35 --customsparams="cd_format=ide\nimage_aio=native"

  It may pass following combination.
  blk+raw
  blk+qcow2+iothread
  scsi+raw+iothread

  It may pass if we put the raw file on non-4k disk, like nfs
  -blockdev node-name=file_image1,driver=file,auto-read-only=on,discard=unmap,aio=native,filename=/home/nfs/win10.raw,cache.direct=on,cache.no-flush=off \
    -blockdev node-name=drive_image1,driver=raw,read-only=off,cache.direct=on,cache.no-flush=off,file=file_image1 \
    -device pcie-root-port,id=pcie-root-port-2,port=0x2,addr=0x1.0x2,bus=pcie.0,chassis=3

  modprobe -r scsi_debug
  modprobe sg
  modprobe scsi_debug lbprz=1 lbpu=1 dev_size_mb=40960 sector_size=4096


#setup
  iscsiadm -m discovery -t st -p 127.0.0.1;iscsiadm -m node -T iqn.2016-06.one.server:one-a  -p 127.0.0.1:3260 -l
  sleep 3;dev="/dev/`lsblk|grep 40G|awk '{ print $1}'`"
  [[ "$dev" == "/dev/" ]] || { mkfs.xfs $dev;mkdir -p /home/scsi;mount $dev /home/scsi;fdisk -l $dev; }

#reset
  umount /home/scsi;iscsiadm -m node -T iqn.2016-06.one.server:one-a -p 127.0.0.1:3260 -u;iscsiadm -m node -T iqn.2016-06.one.server:one-a -p 127.0.0.1:3260 -o delete
  . wiscsi.sh ;wiscsi_clear;wiscsi_restart
  wiscsi_create_one -s 40g -a block_size=4096;wiscsi_restart


  lsblk


}
