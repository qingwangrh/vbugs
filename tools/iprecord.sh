
dir1=/mnt/server1
dir2=/mnt/server2
mkdir -p $dir1
mkdir -p $dir2

mounted=0

echo "Try to record" > /tmp/iprecord.log
while true
do
    #public nfs server
    echo `date` >> /tmp/iprecord.log
    mount 10.73.194.27:/vol/s2images294422/ip  $dir1
    #private nfs server
    mount 10.73.224.36:/home/exports/ip        $dir2
    for d in ${dir1} ${dir2};do
      if mount|grep ${d};then
        hostname=`hostname -s`
        echo "${d}"
        ifconfig >> /tmp/iprecord.log
	mounted=1
	echo "${d}/${hostname}:ok" >> /tmp/iprecord.log
	cp -fr /tmp/iprecord.log ${d}/${hostname}_ip.txt
      fi
    done  
    umount -f $dir1
    umount -f $dir2
    if ((${mounted}==1));then
      break
    else
      echo "Network not ready, wait..."
      sleep 10s
    fi
done



