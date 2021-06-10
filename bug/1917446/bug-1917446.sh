#1917451,1921405,1921409,1917450,1921387,1917449

qemu-img create -f qcow2 /home/kvm_autotest_root/images/ahci-cdrom.img 256M

/usr/libexec/qemu-kvm -nographic -enable-kvm -m 2048 \
    	-device ich9-ahci,id=ahci \
    	-drive file=/home/kvm_autotest_root/images/ahci-cdrom.iso,media=cdrom,if=none,id=mycdrom \
    	-device ide-cd,drive=mycdrom,bus=ahci.0 \
    	/home/kvm_autotest_root/images/rhel840-64-virtio-scsi.qcow2 \




steps() {

dd if=/dev/urandom of=/tmp/orig.dat bs=1M count=100
mkisofs -o /home/kvm_autotest_root/images/ahci-cdrom.iso /tmp/orig.dat
#  guest$
#  guest$ sudo cat /proc/iomem
#  Please confirm there is an "ahci" section in 0xfebf1000.
#  And 0x20000 is inside "SYSTEM RAM".
#
#  guest$ pip3 install python-periphery
#  guest$
#  guest$ sudo python3 ahci.py
#  Wait for about 10 seconds, the qemu should crash (SIGSEGV)


  If the PoC does not work, please try to:
   [1] Set SECTOR_TEST1 in ahci.py to a bigger value like 0xFF.
   [2] Check if PRDTL_VALUE is correct. This value depends on your image,
  normally 0x1300 should work. Here the code validates the value of PRDTL:

  #guest
  cat /proc/iomem |grep ahci

}