case1() {
  qemu-img create -f raw /home/kvm_autotest_root/images/stg0.raw 1G
  virsh define pc.xml
  virsh start pc
}

while true; do
  virsh attach-device pc disk.xml
  virsh detach-device pc disk.xml
done

case2() {
  wloop 0 40 qemu-img create -f qcow2 /home/kvm_autotest_root/images/stg@@.qcow2 1G

  ./bug-1866707.sh

  #then host
  #1866707-host-run.sh
  #then gust

  1866707-guest-run.sh

}
