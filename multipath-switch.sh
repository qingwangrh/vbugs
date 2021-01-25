echo "Usage: mpath [offline-time] example: $0 mpatha 10"
#modprobe scsi_debug dev_size_mb=5000 num_tgts=1 vpd_use_hostno=0 add_host=2 delay=1 max_luns=2 no_lun_0=1

mpath=$1
if [[ "x${mpath}" == "x" ]]; then
  id=$(multipath -l | grep scsi_debug | tr -d "()" | awk 'NR==1{print $2}')
  mpath=$(multipath -l ${id} | grep ${id} | awk 'NR==1{print $1}')
else
  id=$(multipath -l "${mpath}" | tr -d "()" | awk 'NR==1{print $2}')
fi

offline_time=$2
if [[ "x$offline_time" == "x" ]]; then
  offline_time=10
fi

if [[ "x$id" == "x" ]]; then
  echo "Can find scsi_debug multipath ${mpath} or scsi_debug device"
  exit 0
fi

echo "mpath:${mpath} id:${id} offline_time:${offline_time}"

mdevs=$(lsscsi -ik | grep ${id} | awk '{print $6}')

if [[ "x$mdevs" == "x" ]]; then
  echo "Can not found device for ${id}"
  exit 0
fi

mdevs=$(echo "$mdevs" | tr -d "/" | sed s/dev//g)
echo "devs: $mdevs"
#exit 0
echo "Back to running status for all paths"
for dev in $mdevs; do
  echo running >/sys/block/${dev}/device/state
done

sleep 10


while true; do

  for dev in $mdevs; do
    echo "offline ===== ${dev} $(date "+%H:%M:%S")"
    echo offline >/sys/block/${dev}/device/state
    multipath -l $mpath
    sleep $offline_time

    echo "online ====== ${dev} $(date "+%H:%M:%S")"
    echo running >/sys/block/${dev}/device/state
    multipath -l $mpath
#    sleep $offline_time
    sleep 1

    echo
  done
  sleep 1
done

echo "Back to running status for all paths"
for dev in $mdevs; do
  echo running >/sys/block/${dev}/device/state
done
