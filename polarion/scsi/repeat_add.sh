#!/bin/sh

exec_steps() {
  if [[ "X$1" == "X" ]];then
    fmt="blockdev"
  else
    fmt="drive"
  fi
  echo "fmt=$fmt"
  for i in $(seq 7 9); do
    for j in $(seq 0 7); do
      qemu-img create -f qcow2 /tmp/test$i$j.qcow2 1G
    done
  done

  for i in $(seq 7 9); do
    for j in $(seq 1 7); do
      exec 3<>/dev/tcp/localhost/5955
      echo -e "{'execute':'qmp_capabilities'}" >&3
      read response <&3
      echo $response
      sleep 3

      #For blockdev usage:
      if [[ "${fmt}" == "blockdev" ]]; then
        echo "$i-$j"
        echo -e "{'execute':'blockdev-add','arguments':{'node-name':'data_drive$i$j','driver':'qcow2','file':{'driver':'file','filename':'/tmp/test$i$j.qcow2','aio':'native','cache': {'direct': true, 'no-flush': false}}}}" >&3
      elif [[ "${fmt}" == "drive_old" ]]; then
        #For drive usage:
        #slow
        echo -e "{'execute':'__com.redhat_drive_add', 'arguments': {'file':'/tmp/test$i$j.qcow2','format':'qcow2','id':'data_drive$i$j','cache':'none','aio':'native'}}" >&3
      else
        #fast
        echo -e "{'execute': 'human-monitor-command', 'arguments': {'command-line': 'drive_add auto id=data_drive$i$j,if=none,snapshot=off,aio=native,cache=none,format=qcow2,file=/tmp/test$i$j.qcow2'}}">&3
      fi
      read response <&3
      echo $response
      sleep 3
      echo -e "{'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'data_drive$i$j','id':'data$i$j','addr':'0x$i.$j','multifunction':'on'}}" >&3
      read response <&3
      echo $response
      sleep 3
    done

    #    For blockdev usage:
    #    echo -e "{'execute':'blockdev-add','arguments':{'node-name':'data_drive${i}0','driver':'qcow2','file':{'driver':'file','filename':'/tmp/test${i}0.qcow2','aio':'native','cache': {'direct': true, 'no-flush': false}}}}" >&3
    #
    #    For drive usage:
    #    echo -e "{'execute':'__com.redhat_drive_add', 'arguments': {'file':'/tmp/test${i}0.qcow2','format':'qcow2','id':'data_drive${i}0','cache':'none','aio':'native'}}" >&3
    #
    #    read response <&3
    #    echo $response
    #    sleep 3
    #    echo -e "{'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'data_drive${i}0','id':'data${i}0','addr':'0x${i}.0','multifunction':'on'}}" >&3
    #    read response <&3
    #    echo $response
    #    sleep 3


  done

}


#{'execute':'blockdev-add','arguments':{'node-name':'data_drive70','driver':'qcow2','file':{'driver':'file','filename':'/tmp/test70.qcow2','aio':'native','cache': {'direct': true, 'no-flush': false}}}}
#{'execute':'device_add', 'arguments': {'driver':'virtio-blk-pci','drive':'data_drive70','id':'data70','addr':'0x7.0','multifunction':'on'}}
exec_steps $1
