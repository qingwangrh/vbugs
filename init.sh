
#This tools for new host to setup basic env
source ./common.sh
#src_dir=/home/workdir
#create_workdir(){
#  echo "create_workdir"
#  [ -d /workdir ] || mkdir -p /workdir
#  [ -d ${src_dir} ] || mkdir -p ${src_dir}
#
#  if mount|grep ' /workdir';then
#    echo "Already mount workdir"
#  else
#    echo "mount ${src_dir}"
#    if mount -o bind ${src_dir} /workdir ;then
#      sed -i '$a\/home/workdir           /workdir                none    rw,bind         0 0' /etc/fstab
#    else
#        echo "ERROR on mount ${src_dir}"
#        exit 1
#    fi
#  fi
#}
#
#mount_resource(){
#  mkdir -p /home/kvm_autotest_root/iso
#  mkdir -p /home/workdir/exports
#  mount 10.73.194.27:/vol/s2kvmauto/iso  /home/kvm_autotest_root/iso
#  mount 10.66.8.105:/home/exports /workdir/exports
#}

create_workdir
mount_resource