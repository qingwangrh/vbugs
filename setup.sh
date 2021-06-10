
#This tools for install qemu
source ./common.sh

usage_help(){
  if uname -r |grep el8;then
    echo "python3 component_management.py --install-virtqemu ID --verbose"
  elif uname -r |grep el7;then
    echo -e "brew download-build --debuginfo --arch=x86_64  qemu-kvm-rhev-XXX\nyum remove qemu-kvm qemu-kvm-tools qemu-kvm-common qemu-kvm-rhev-debuginfo qemu-img-rhev\nyum install *"
  else
    echo "Warning nothing to do"
  fi
  if which efibootmgr;then
    efibootmgr -v
  else
    echo "Not found efibootmgr"
  fi
}

export https_proxy=http://squid.corp.redhat.com:3128
create_workdir
create_cert
create_component_manager
create_repo
open_coredump
disable_firewalld
create_network

create_kar
usage_help
