#This tools for new host to setup basic env
#set -x
src_dir=/home/workdir
create_workdir() {
  echo "create_workdir"
  [[ -d /workdir ]] || mkdir -p /workdir
  [[ -d ${src_dir} ]] || mkdir -p ${src_dir}

  if mount | grep 'on */workdir '; then
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
#create_workdir
#mount_resource
