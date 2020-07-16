#https://wiki.qemu.org/Documentation/9psetup

mkdir -p /home/tmp/share

qemu-img create -f qcow2 /home/kvm_autotest_root/images/foo.qcow2 10M
