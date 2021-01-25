#!/bin/bash
VM=$1
INTVAL=5

date
virsh start $VM
for i in {1..1000};do
    while [ "$(virsh guestinfo $VM )" == "" ];do
        if [ "$(virsh domstate $VM)" == "paused" ];then
            date
            echo "VM is paused"
            break 2
        fi
        sleep 3
    done
    echo "`date` $i reboot"
    virsh reboot $VM --mode agent
    sleep $INTVAL
done
echo "End"