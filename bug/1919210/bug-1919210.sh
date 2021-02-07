#bug 1921546,bug 1921547,bug 1921549,bug 1921548

cat << EOF | /usr/libexec/qemu-kvm -display none -machine accel=qtest \
-m 512M -machine pc -device floppy,unit=1,id=floppy0,drive=disk0 \
-drive id=disk0,file=null-co://,file.read-zeroes=on,if=none,format=raw \
-qtest stdio
outw 0x3f4 0x2500
outb 0x3f5 0x81
outb 0x3f5 0x0
outb 0x3f5 0x0
outb 0x3f5 0x0
outw 0x3f2 0x14
outw 0x3f4 0x0
outw 0x3f4 0x4000
outw 0x3f4 0x13
outb 0x3f5 0x1
outw 0x3f2 0x1405
outw 0x3f4 0x0
EOF


steps() {
#rhel7
#qemu-kvm: -drive id=disk0,file=null-co://,file.read-zeroes=on,if=none,format=raw: could not open
# disk image null-co://: Unknown protocol

/usr/libexec/qemu-kvm -display none -machine accel=qtest \
-m 512M -machine pc -device floppy,unit=1,id=floppy0,drive=disk0 \
-qtest stdio \
-drive id=disk0,file=/dev/null,file.read-zeroes=on,if=none,format=raw \


}