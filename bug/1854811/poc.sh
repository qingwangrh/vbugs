sudo virsh suspend testpoc
sudo virsh attach-device testpoc 1854811-disk.xml
sleep 1
sudo virsh resume testpoc
