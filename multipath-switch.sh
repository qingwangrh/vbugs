mtime=$1
shift
mpath=$@
if [[ "x$mpath" == "x" ]]; then
  echo "Usage: time sdb sdc"
  exit
fi

for dev in $mpath; do
    echo running >/sys/block/${dev}/device/state
    sleep 3
done
while true; do

  for dev in $mpath; do
    echo "offline ===== ${dev}"
    echo offline >/sys/block/${dev}/device/state
    multipath -l | grep ${dev}
    multipath -l
    sleep $mtime
    echo running >/sys/block/${dev}/device/state
    echo "online ===== ${dev}"
    multipath -l | grep ${dev}
    multipath -l
    sleep $mtime
    echo
  done
  sleep 1
  multipath -l
done
for dev in $mpath; do
  echo running >/sys/block/${dev}/device/state
done
