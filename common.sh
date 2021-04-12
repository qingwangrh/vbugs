#This tools for new host to setup basic env
#set -x

q_src_dir=/home/

create_workdir() {
  echo "create_workdir"
  [[ -d /home/kvm_autotest_root/iso ]] || mkdir -p /home/kvm_autotest_root/iso
  [[ -d /home/kvm_autotest_root/images ]] || mkdir -p /home/kvm_autotest_root/images
  [[ -d ${q_src_dir} ]] || mkdir -p ${q_src_dir}

  #  if ! grep " /workdir" /etc/fstab; then
  #    sed -i '$a\/home  /workdir  none    rw,bind    0 0' /etc/fstab
  #  fi

}

create_cert() {
  echo "create_cert"

  curl -kL 'https://password.corp.redhat.com/RH-IT-Root-CA.crt' -o /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt
  curl -kL 'https://password.corp.redhat.com/legacy.crt' -o /etc/pki/ca-trust/source/anchors/legacy.crt
  curl -kL 'https://engineering.redhat.com/Eng-CA.crt' -o /etc/pki/ca-trust/source/anchors/Eng-CA.crt
  update-ca-trust enable
  update-ca-trust extract
}

create_component_manager() {
  echo "create_component_manager"
  curl -Lk http://git.host.prod.eng.bos.redhat.com/git/kvmqe-ci.git/tree/utils/beaker-workflow/ks/el8.ks -o /tmp/el8.ks
  sed -n '/base64 -d.*component_management/,/chmod .*component_management/p' /tmp/el8.ks >/tmp/create_component_manager_x.sh
  #  sed -e 's/\/root/\/home\/workdir/' -e 's/&lt;/</g' -e 's/&gt;/>/' /tmp/create_component_manager_x.sh >/tmp/create_component_manager_y.sh
  sed -e 's/&lt;/</g' -e 's/&gt;/>/' /tmp/create_component_manager_x.sh >/tmp/create_component_manager_y.sh
  /bin/sh /tmp/create_component_manager_y.sh
  cp ~/component_management.py /home -rf

}

create_repo7() {
  echo "create_repo7"
  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-7-server.repo' -o /etc/yum.repos.d/rcm-tools-rhel-7.repo
  rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum install python2-pip python3 brewkoji git vim net-tools screen mlocate -y
  updatedb
  pip install --upgrade pip
  pip install Jinja2
}

create_repo8() {
  echo "create_repo8"
  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
  #  dnf install python3 brewkoji  git -y
  yum install http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/screen/4.6.2/4.el8/x86_64/screen-4.6.2-4.el8.x86_64.rpm -y
  yum install python3 brewkoji git vim net-tools mlocate -y
  updatedb
}

create_repo9() {
  echo "create_repo9"
  #  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
  #  dnf install python3 brewkoji  git -y
  yum install -y http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/screen/4.6.2/4.el8/x86_64/screen-4.6.2-4.el8.x86_64.rpm
  #  yum install python3 brewkoji git vim net-tools mlocate -y
  yum install -y nfs-utils git vim net-tools mlocate
  yum install -y qemu*
  yum install -y http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/brewkoji/1.26/1.el9/noarch/brewkoji-1.26-1.el9.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/brewkoji/1.26/1.el9/noarch/python3-brewkoji-1.26-1.el9.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/brewkoji/1.26/1.el9/noarch/brewkoji-qe-1.26-1.el9.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/brewkoji/1.26/1.el9/noarch/brewkoji-stage-1.26-1.el9.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/koji/1.23.1/1.el9/noarch/python3-koji-1.23.1-1.el9.noarch.rpm http://download.eng.bos.redhat.com/brewroot/vol/rhel-9/packages/koji/1.23.1/1.el9/noarch/koji-1.23.1-1.el9.noarch.rpm
  updatedb
}

create_repo() {
  if uname -r | grep el9; then
    create_repo9
  elif uname -r | grep el8; then
    create_repo8
  elif uname -r | grep el7; then
    create_repo7
  else
    echo "Warning nothing to do"
  fi
}

mount_resource() {

  [[ -d /home/kvm_autotest_root/iso ]] || mkdir -p /home/kvm_autotest_root/iso
  if ! mount | grep '/home/kvm_autotest_root/iso'; then
    echo "mount 10.73.194.27:/vol/s2kvmauto/iso /home/kvm_autotest_root/iso"
    mount 10.73.194.27:/vol/s2kvmauto/iso /home/kvm_autotest_root/iso
  fi

}

_setup_bridge() {
  #Get the Ethernet interface
  NDEV=$(ip route | grep default | grep -Po '(?<=dev )(\S+)' | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $1}')
  #Get connection name
  CONID=$(nmcli device show $NDEV | awk -F: '/GENERAL.CONNECTION/ {print $2}' | awk '{$1=$1}1')

  MAC=$(nmcli device show $NDEV | grep GENERAL.HWADDR | awk '{print $2}')
  if uname -r | grep el9; then
    nmcli con add type bridge ifname "$BRIDGE_IFNAME" con-name "$BRIDGE_IFNAME" stp no 802-3-ethernet.cloned-mac-address $MAC
  else
    nmcli con add type bridge ifname "$BRIDGE_IFNAME" con-name "$BRIDGE_IFNAME" stp no
  fi
  nmcli con modify "$CONID" master "$BRIDGE_IFNAME"
  nmcli con up "$CONID"
  [ $? -ne 0 ] && echo "NetworkManager Command failed" && return 1
}

_chk_bridge_dev_ip() {
  ## Check whether bridge device gets ip address
  START=$(date +%s)
  while [ $(($(date +%s) - 120)) -lt $START ]; do
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

  base64 -d <<EOF >/etc/qemu-ifup
IyEvYmluL3NoCnN3aXRjaD1zd2l0Y2gKL3Vzci9zYmluL2lwIGxpbmsgc2V0ICQxIHVwCi91c3Iv
c2Jpbi9pcCBsaW5rIHNldCBkZXYgJDEgbWFzdGVyICR7c3dpdGNofQovdXNyL3NiaW4vaXAgbGlu
ayBzZXQgJHtzd2l0Y2h9IHR5cGUgYnJpZGdlIGZvcndhcmRfZGVsYXkgMAovdXNyL3NiaW4vaXAg
bGluayBzZXQgJHtzd2l0Y2h9IHR5cGUgYnJpZGdlIHN0cF9zdGF0ZSAwCg==
EOF

  base64 -d <<EOF >/etc/qemu-ifdown
IyEvYmluL3NoCnN3aXRjaD1zd2l0Y2gKL3Vzci9zYmluL2lwIGxpbmsgc2V0ICQxIGRvd24KL3Vz
ci9zYmluL2lwIGxpbmsgc2V0IGRldiAkMSBub21hc3Rlcgo=
EOF
  chmod a+rx /etc/qemu-if*

}
create_network() {
  BRIDGE_IFNAME='switch'

  if ! nmcli -t device show switch; then
    echo "create bridge switch"
    # cp setup_bridge.sh ~/
    # /bin/sh ~/setup_bridge.sh
    _setup_bridge
    _chk_bridge_dev_ip
  fi

  [[ -f /etc/qemu-ifup ]] || _setup_qemu_if

}

create_kar() {
  export https_proxy=http://squid.corp.redhat.com:3128
  local usage="create_kar [-v disable venv] [-s stable] [-o options]"
  local OPT OPTARG OPTIND others
  local vflag="1"
  local options=" --develop --upstream --verbose "
  while getopts 'o:vsh' OPT; do
    case $OPT in
    o) others="$OPTARG" ;;
    v) vflag="0" ;;
    s) sflag="1" ;;
    h) echo -e ${usage} ;;
    ?) echo -e ${usage} ;;
    esac
  done
  [[ "$vflag" == "1" ]] && options="$options --venv "
  [[ "$sflag" == "1" ]] && options="$options --stable "
  options="$options $others "
  echo "options:$options"
  DIR=$(pwd)
  cd ${q_src_dir}
  STAMP=$(date "+%m%d-%H%M")
  [ -e kar ] && {
    mkdir -p oldkar
    mv kar oldkar/kar${STAMP}
  }
  git clone https://gitlab.cee.redhat.com/kvm-qe/kar.git
  cd kar

  ./Bootstrap.sh $options
  #  ./Bootstrap.sh --develop --verbose --venv --avocado-pt=80.0 $target

  if [[ "$vflag" == "1" ]]; then
    pathfix="workspace"
    venv="venv"
  else
    ln -s ~/avocado/job-results workspace/job-results
  fi
  ln -s $pathfix/var/lib/avocado/data/avocado-vt/virttest/test-providers.d/downloads/io-github-autotest-qemu tp-qemu
  ln -s workspace/avocado-vt avocado-vt
  ln -s $pathfix/var/lib/avocado/data/avocado-vt/backends/qemu/cfg output-cfg

  touch $venv${STAMP}
  if uname -r | grep el9; then
    #temp
    wget http://fileshare.englab.nay.redhat.com/pub/section2/kvm/xuwei/rhel9_installation/RHEL-9-series.ks
    cp -rf RHEL-9-series.ks internal_ks/RHEL-9-series.ks
  fi
  #git clone https://gitlab.cee.redhat.com/yhong/vmt.git
  cd ${DIR}
}

open_coredump() {
  yum install abrt abrt-addon-ccpp abrt-tui -y
  mkdir -p /home/core/
  echo "/home/core/core.%e.%p.%h.%t" >/proc/sys/kernel/core_pattern
  #sed -i -e '1,$s/#ProcessSizeMax=2G/ProcessSizeMax=32G/g' -e '1,$s/#ExternalSizeMax=2G/ExternalSizeMax=32G/g' /etc/systemd/coredump.conf
  sed -i -e '$a\ExternalSizeMax=32G' -e '$a\ProcessSizeMax=32G' /etc/systemd/coredump.conf
  ulimit -a
  sed -i '$a\*          soft     core   unlimited' /etc/security/limits.conf
  echo "*   soft noproc   65535" >>/etc/security/limits.conf
  echo "*   hard noproc   65535" >>/etc/security/limits.conf
  echo "*   soft nofile   265535" >>/etc/security/limits.conf
  echo "*   hard nofile   65535" >>/etc/security/limits.conf

  cat /etc/security/limits.conf
  cat /etc/systemd/coredump.conf
  systemctl daemon-reload
  #systemctl restart abrtd.service
  #systemctl restart abrt-ccpp.service
  #/var/spool/abrt

}

disable_firewalld() {
  systemctl stop firewalld
  systemctl disable firewalld
  setenforce 0
  sed -i -e '$a\SELINUX=disabled' -e '/SELINUX=enforcing/d' /etc/sysconfig/selinux

}

create_libvirt_repo() {
  local vers=$(cat /etc/redhat-release | awk '{print $6}')
  cp -rf libvirt-$vers.repo /etc/yum.repos.d/
  yum -y module reset virt
  #yum module list
  yum -y module enable virt:av
  yum -y module install virt:av
  #  yum -y remove qemu-kvm*
  #  yum -y install qemu-kvm
  #  yum -y install libvirt*

  echo "log_level = 3" >>/etc/libvirt/libvirtd.config
  echo "log_filters=\"1:qemu 1:libvirt\"" >>/etc/libvirt/libvirtd.config
  echo "log_outputs=\"1:file:/tmp/libvirtd.log\"" >>/etc/libvirt/libvirtd.config

  echo "max_core = \"unlimited\"" >>/etc/libvirt/qemu.conf

}
