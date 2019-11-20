
#This tools for install qemu
src_dir=/home/workdir
create_workdir(){
  echo "create_workdir"
  [ -d /workdir ] || mkdir -p /workdir
  [ -d ${src_dir} ] || mkdir -p ${src_dir}

  if mount|grep workdir;then
    echo "Already mount workdir"
  else
    echo "mount ${src_dir}"
    if mount -o bind ${src_dir} /workdir ;then
      sed -i '$a\/home/workdir           /workdir                none    rw,bind         0 0' /etc/fstab
    else
        echo "ERROR on mount ${src_dir}"
        exit 1
    fi
  fi
}

create_cert(){
  echo "create_cert"
  curl -Lk https://gitlab.cee.redhat.com/pingl/script_repo/raw/master/component_management.py -o /home/workdir/component_management.py
  curl -kL 'https://password.corp.redhat.com/RH-IT-Root-CA.crt' -o /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt
  curl -kL 'https://password.corp.redhat.com/legacy.crt' -o /etc/pki/ca-trust/source/anchors/legacy.crt
  curl -kL 'https://engineering.redhat.com/Eng-CA.crt' -o /etc/pki/ca-trust/source/anchors/Eng-CA.crt
  update-ca-trust enable
  update-ca-trust extract
}

create_repo7(){
  echo "create_repo7"
  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-7-server.repo' -o /etc/yum.repos.d/rcm-tools-rhel-7.repo
  rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  yum install python3 brewkoji git vim net-tools screen -y
}

create_repo8(){
  echo "create_repo8"
  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
#  dnf install python3 brewkoji  git -y
  yum install http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/screen/4.6.2/4.el8/x86_64/screen-4.6.2-4.el8.x86_64.rpm -y
  yum install python3 brewkoji git vim net-tools -y
}
#  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
#  dnf install python3 brewkoji  git -y

#  yum install http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/screen/4.6.2/4.el8/x86_64/screen-4.6.2-4.el8.x86_64.rpm -y

create_repo(){
  if uname -r |grep el8;then
    create_repo8
  elif uname -r |grep el7;then
    create_repo7
  else
    echo "Warning nothing to do"
  fi
}

create_kar(){
  echo "create_kar"
  cd ${src_dir}
  git clone https://gitlab.cee.redhat.com/kvm-qe/kar.git
  git clone https://gitlab.cee.redhat.com/yhong/vmt.git
  cd -
}

usage_help(){
  if uname -r |grep el8;then
    echo "python3 component_management.py --install-virtqemu ID --verbose"
  elif uname -r |grep el7;then
    echo -e "brew download-build --debuginfo --arch=x86_64  qemu-kvm-rhev-XXX\nyum remove qemu-kvm qemu-kvm-tools qemu-kvm-common qemu-kvm-rhev-debuginfo qemu-img-rhev\nyum install *"
  else
    echo "Warning nothing to do"
  fi
}


create_workdir
create_cert
create_repo
create_kar
usage_help
