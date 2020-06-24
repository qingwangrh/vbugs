#!/bin/bash
#/home/code/iprecord.sh

#chmod +x /etc/rc.d/rc.local
#/bin/sh /home/code/iprecord.sh &
#systemctl enable rc-local.service
#systemctl start rc-local.service
#systemctl status rc-local.service
#vim /lib/systemd/system/rc-local.service


dirs=(/mnt/server1 /mnt/server2 /mnt/server3)
#public nfs server
servers[0]=10.73.194.27:/vol/s2images294422/ip
#private nfs server
servers[1]=10.66.11.29:/home/exports/ip
servers[2]=10.66.8.105:/home/exports/ip

echo "Try to record" > /tmp/iprecord.log

while true
do
for idx in 0 1 2
do
    echo `date` >> /tmp/iprecord.log
    echo "Try to record to ${servers[$idx]}" >> /tmp/iprecord.log
    mkdir -p ${dirs[$idx]}

    mount ${servers[$idx]} ${dirs[$idx]}
    ls ${dirs[$idx]} >> /tmp/iprecord.log
    if mount|grep ${dirs[$idx]};then
        hostname=`hostname -s`
        ifconfig >> /tmp/iprecord.log
        mounted=1
        echo "${servers[$idx]}/${hostname}:ok" >> /tmp/iprecord.log
        cp -fr /tmp/iprecord.log ${dirs[$idx]}/${hostname}_ip.txt
        umount ${dirs[$idx]}
        echo "Finish on ${hostname} ${servers[$idx]} ${dirs[$idx]}"
        echo "Finish on ${hostname} ${servers[$idx]} ${dirs[$idx]}" >> /tmp/iprecord.log
        break
    else
        echo "Network not ready, wait..."
        echo "Failed on ${hostname} ${servers[$idx]} ${dirs[$idx]}" >> /tmp/iprecord.log
        sleep 10s
    fi
done
    if ((${mounted}==1));then
          break
    fi
done

