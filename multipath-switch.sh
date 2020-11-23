echo "Usage: time mapper"

mtime=$1
if [[ "x$mtime" == "x" ]]; then
  mtime=10
fi
shift
mdevs=$@
if [[ "x$mdevs" == "x" ]]; then
  id=$(multipath -l | grep scsi_debug | tr -d "()" | cut -f 1,2 -d " ")
else
  id=$(multipath -l $mdevs | tr -d "()" | cut -f 1,2 -d " ")
fi

if [[ "x$id" == "x" ]]; then
  echo "Can find scsi_debug multipath device"
  exit 0
fi
echo "$id"
mpath=`echo "$id"|awk '{print $1}'`
id=`echo "$id"|awk '{print $2}'`

mdevs=$(lsscsi -ik | grep $id | awk '{print $6}')

if [[ "x$mdevs" == "x" ]]; then
  echo "Can not found device for $id"
  exit 0
fi
echo "$mdevs"
mdevs=$(echo "$mdevs"|tr -d "/"|sed s/dev//g)
echo "$mdevs"
for dev in $mdevs; do
  echo running >/sys/block/${dev}/device/state
  sleep 3
done
while true; do

  for dev in $mdevs; do
    echo "offline ===== ${dev}"
    echo offline >/sys/block/${dev}/device/state
#    multipath -l | grep ${dev}
    multipath -l $mpath
    sleep $mtime
    echo running >/sys/block/${dev}/device/state
    echo "online ===== ${dev}"
#    multipath -l | grep ${dev}
    multipath -l $mpath
#    sleep $mtime
    sleep 5
    echo
  done
  sleep 1
#  multipath -l
done
for dev in $mdevs; do
  echo running >/sys/block/${dev}/device/state
done
