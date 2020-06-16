#This tools for new host to setup basic env
#set -x
src_dir=/home/workdir
create_workdir() {
  echo "create_workdir"
  [[ -d /workdir ]] || mkdir -p /workdir
  [[ -d ${src_dir} ]] || mkdir -p ${src_dir}
  mkdir -p /home/rexports
  mkdir -p /home/rworkdir

  if mount | grep ' /workdir '; then
    echo "Already mount workdir"
  else
    echo "mount ${src_dir}"
    if ! mount -o bind ${src_dir} /workdir; then
      echo "ERROR on mount ${src_dir}"
      exit 1
    fi
    if ! grep "/home/workdir" /etc/fstab;then
      sed -i '$a\/home/workdir           /workdir                none    rw,bind         0 0' /etc/fstab
    fi
  fi

}

mount_resource() {

  [[ -d /home/kvm_autotest_root/iso ]] || mkdir -p /home/kvm_autotest_root/iso
  [[ -d /home/workdir/exports ]] || mkdir -p /home/workdir/exports
  if ! mount | grep '/home/kvm_autotest_root/iso';then
	echo "mount 10.73.194.27:/vol/s2kvmauto/iso /home/kvm_autotest_root/iso"
	mount 10.73.194.27:/vol/s2kvmauto/iso /home/kvm_autotest_root/iso
  fi
  #if ! mount | grep '/workdir/exports';then
  #	echo "mount 10.66.8.105:/home/exports /workdir/exports"
  #	mount 10.66.8.105:/home/exports /workdir/exports
  #fi

}

common_env() {
  echo "common_env $@"
  if [[ "x$1" == "x" ]]; then
    idx=0
  else
    idx=$1
  fi
  os_img="rhel820-${idx}.qcow2"

  if [[ "x$2" == "x" ]]; then
    os_img="rhel820-${idx}.qcow2"
  else
    os_img=$2
  fi

  MAC="9a:b5:b6:b1:b2:b${idx}"
  port="595${idx}"
  vnc="1${idx}"
  data1_img="data${idx}-1.qcow2"
  data2_img="data${idx}-2.qcow2"
  data3_img="data${idx}-3.qcow2"
  img_dir=/home/kvm_autotest_roo
  img_dir=/home/kvm_autotest_root/images
  iso_dir=/home/kvm_autotest_root/iso
  [ -d ${iso_dir} ] || mkdir -p ${iso_dir}

  if ! mount | grep ${iso_dir}; then
    mount 10.73.194.27:/vol/s2kvmauto/iso ${iso_dir}
  fi
  [ -f ${img_dir}/${data1_img} ] || qemu-img create -f qcow2 ${img_dir}/${data1_img} 1G
  [ -f ${img_dir}/${data2_img} ] || qemu-img create -f qcow2 ${img_dir}/${data2_img} 2G
  [ -f ${img_dir}/${data3_img} ] || qemu-img create -f qcow2 ${img_dir}/${data3_img} 3G
}

env_print(){
  echo "${idx}"
  echo "${os_img}"
  echo "${img_dir}"
}


_setup_bridge()
{
    #Get the Ethernet interface
    NDEV=$(ip route | grep default | grep -Po '(?<=dev )(\S+)' | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $1}')
    #Get connection name
    CONID=$(nmcli device show $NDEV | awk -F: '/GENERAL.CONNECTION/ {print $2}' | awk '{$1=$1}1')

    nmcli con add type bridge ifname "$BRIDGE_IFNAME" con-name "$BRIDGE_IFNAME" stp no
    nmcli con modify "$CONID" master "$BRIDGE_IFNAME"
    nmcli con up "$CONID"
    [ $? -ne 0 ] && echo "NetworkManager Command failed" && return 1
}

_chk_bridge_dev_ip()
{
    ## Check whether bridge device gets ip address
    START=`date +%s`
    while [ $(( $(date +%s) - 120 )) -lt $START ]; do
        IP_ADDR=$(ip address show "$BRIDGE_IFNAME" | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
        [[ -n "$IP_ADDR" ]] && echo "ip address of bridge device '$BRIDGE_IFNAME': $IP_ADDR" && return 0
        sleep 5
    done
    echo "Fail to get ip address of bridge device '$BRIDGE_IFNAME' in 2 mins"
    return 1
}

_setup_qemu_if() {
content="
/etc/qemu-ifup

#!/bin/sh
switch=switch
/usr/sbin/ip link set $1 up
/usr/sbin/ip link set dev $1 master ${switch}
/usr/sbin/ip link set ${switch} type bridge forward_delay 0
/usr/sbin/ip link set ${switch} type bridge stp_state 0

/etc/qemu-ifdown
#!/bin/sh
switch=switch
/usr/sbin/ip link set $1 down
/usr/sbin/ip link set dev $1 nomaster
"

  base64 -d <<EOF > /etc/qemu-ifup
IyEvYmluL3NoCnN3aXRjaD1zd2l0Y2gKL3Vzci9zYmluL2lwIGxpbmsgc2V0ICQxIHVwCi91c3Iv
c2Jpbi9pcCBsaW5rIHNldCBkZXYgJDEgbWFzdGVyICR7c3dpdGNofQovdXNyL3NiaW4vaXAgbGlu
ayBzZXQgJHtzd2l0Y2h9IHR5cGUgYnJpZGdlIGZvcndhcmRfZGVsYXkgMAovdXNyL3NiaW4vaXAg
bGluayBzZXQgJHtzd2l0Y2h9IHR5cGUgYnJpZGdlIHN0cF9zdGF0ZSAwCg==
EOF


  base64 -d <<EOF > /etc/qemu-ifdown
IyEvYmluL3NoCnN3aXRjaD1zd2l0Y2gKL3Vzci9zYmluL2lwIGxpbmsgc2V0ICQxIGRvd24KL3Vz
ci9zYmluL2lwIGxpbmsgc2V0IGRldiAkMSBub21hc3Rlcgo=
EOF
  chmod a+rx /etc/qemu-if*

}
create_network(){
BRIDGE_IFNAME='switch'

if ! nmcli -t device show switch;then
echo "create bridge switch"
# cp setup_bridge.sh ~/
# /bin/sh ~/setup_bridge.sh
  _setup_bridge
  _chk_bridge_dev_ip
fi

[[ -f /etc/qemu-ifup ]] || _setup_qemu_if

}
#create_workdir
#mount_resource
