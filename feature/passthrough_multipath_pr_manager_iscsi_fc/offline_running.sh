while true
do
for dev in sdb sdc
do
	echo "offline ===== ${dev}"
	echo offline > /sys/block/${dev}/device/state
	sleep 5
	multipath -l |grep ${dev}
	sleep 5
	echo running > /sys/block/${dev}/device/state
	echo "online ===== ${dev}"
	multipath -l |grep ${dev}

done
	sleep 1
	multipath -l
done
