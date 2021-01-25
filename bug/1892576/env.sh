1.copy qing /home/windbg/pub*.qcow2
2.create iscsi server on host1
vbug/wiscsi.sh
wiscsi_deploy
wiscsi_create
systemctl enable targetclid
3.change
/etc/iscsi/initiatorname.iscsi
systemctl restart iscsi;systemctl restart iscsid

4.change multipath

/sbin/mpathconf --enable
cat /etc/multipath.conf

defaults {
        user_friendly_names yes
        find_multipaths yes
        enable_foreign "^$"
        reservation_key file
}
systemctl restart multipathd
reboot

5.login iscsi
iscsiadm -m discovery -t st -p 10.73.196.27
iscsiadm -m node -T iqn.2016-06.share.server:4g-a -p 10.73.196.27:3260 -l
iscsiadm -m node -T iqn.2016-06.share.server:4g-b -p 10.73.196.27:3260 -l

systemctl restart multipathd

boot guest set dns to domain
foramt disk then reboot guest

systemctl enable qemu-pr-helper;systemctl start qemu-pr-helper;  systemctl status qemu-pr-helper
systemctl enable target;systemctl start target
mount 10.73.194.27:/vol/s2kvmauto/iso  /home/kvm_autotest_root/iso
