
  mkdir -p /workdir
  mkdir -p /home/workdir

  src_dir=/home/workdir
  if mount|grep workdir;then
    echo "already mount workdir"
  else

    if mount -o bind /home/workdir /workdir ;then
      sed -i '$a\/home/workdir           /workdir                none    rw,bind         0 0' /etc/fstab
    fi

  fi

  curl -Lk https://gitlab.cee.redhat.com/pingl/script_repo/raw/master/component_management.py -o /home/workdir/component_management.py
  curl -kL 'https://password.corp.redhat.com/RH-IT-Root-CA.crt' -o /etc/pki/ca-trust/source/anchors/RH-IT-Root-CA.crt
  curl -kL 'https://password.corp.redhat.com/legacy.crt' -o /etc/pki/ca-trust/source/anchors/legacy.crt
  curl -kL 'https://engineering.redhat.com/Eng-CA.crt' -o /etc/pki/ca-trust/source/anchors/Eng-CA.crt
  update-ca-trust enable
  update-ca-trust extract

  curl -kL 'http://download.eng.bos.redhat.com/rel-eng/internal/rcm-tools-rhel-8-baseos.repo' -o /etc/yum.repos.d/rcm-tools-rhel-8.repo
  dnf install python3 brewkoji  git -y

  yum install http://download.eng.bos.redhat.com/brewroot/vol/rhel-8/packages/screen/4.6.2/4.el8/x86_64/screen-4.6.2-4.el8.x86_64.rpm -y

  cd /home/workdir
  git clone https://gitlab.cee.redhat.com/kvm-qe/kar.git
  git clone https://gitlab.cee.redhat.com/yhong/vmt.git