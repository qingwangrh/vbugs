#iscsi relevant operations

clienta="iqn.1994-05.com.redhat:clienta"
clientb="iqn.1994-05.com.redhat:clientb"

wiscsi_deploy() {
  #deploy targetcli
  mkdir -p /etc/target/pr
  mkdir -p /home/iscsi/
  yum install targetcli -y
  systemctl enable target
  systemctl start target
  systemctl enable targetcli
  systemctl start targetcli
  #  dd if=/dev/zero of=/home/iscsi/share4g.img bs=1M count=4096
  #  dd if=/dev/zero of=/home/iscsi/share10g.img bs=1M count=10240
  targetcli clearconfig confirm=True
}

wiscsi_clear() {
  targetcli clearconfig confirm=True
  targetcli saveconfig
  systemctl restart target
  #iscsi iscsid
}

wiscsi_logout() {
  local file=/tmp/iscsi
  local usage="wiscsi_logout [-t targets]"

  while getopts 't:h' OPT; do
    case $OPT in
    t) targets="$OPTARG" ;;
    h) echo -e ${usage};return 0 ;;
    ?) echo -e ${usage};return 0 ;;
    esac
  done
  if ! iscsiadm -m session >$file; then
    echo "No session found"
    return 1
  fi
  if [[ "$targets" == "" ]]; then
    targets=$(cat $file)
  fi
  cat $file | while read LINE; do
    echo $LINE
    portal=$(echo $LINE | awk '{print $3}' | cut -f 1 -d ",")
    target=$(echo $LINE | awk '{print $4}')
    echo "$portal"
    echo "$target"
    if echo "$targets" | grep $target; then
      iscsiadm -m node -T $target -p $portal -u
      iscsiadm -m node -T $target -p $portal -o delete
    fi
  done
  iscsiadm -m session
}

wiscsi_create() {
  local usage="usage: -l lun_name -n [dev/file] name -t targets -b backend [block/fileio] -c clients -s size [ -a attrs]
example: -l disk0 -n /home/iscsi/share4g.img -t iqn.2016-06.one.server:4g -b fileio -c iqn.1994-05.com.redhat:clienta"
  local OPT OPTARG OPTIND
  #  local backend="fileio"
  local attrs
  echo "Params:$#: $@"
  while getopts 't:a:l:b:c:s:n:h' OPT; do
    case $OPT in
    t) targets="$OPTARG" ;;
    n) name="$OPTARG" ;;
    l) lun="$OPTARG" ;;
    c) clients="$OPTARG" ;;
    b) backend="$OPTARG" ;;
    s) size="$OPTARG" ;;
    a) attrs="$OPTARG" ;;
    h)
      echo -e ${usage}
      return 0
      ;;
    ?)
      echo -e ${usage}
      return 0
      ;;
    esac
  done

  [[ "${targets}" == "" ]] && { echo -e "No targets:\n${usage}" && return 0; }
  [[ "${lun}" == "" ]] && { echo -e "No lun:\n${usage}" && return 0; }
  [[ "${name}" == "" ]] && { echo -e "No name:\n${usage}" && return 0; }
  [[ "${backend}" == "" ]] && { echo -e "No backend:\n${usage}" && return 0; }
  [[ "${clients}" == "" ]] && { echo -e "No clients:\n${usage}" && return 0; }
  [[ "${backend}" == "fileio" ]] && rm ${name} -rf
  echo -e "T: ${targets} \nL: ${lun} \nN: ${name} \nB: ${backend} \nC: ${clients} \nS: ${size} \nA: ${attrs} \n"

  if ! targetcli / ls /backstores/${backend}/${lun}; then
    echo "Ready to targetcli /backstores/${backend} create ${lun} ${name} ${size}"
    targetcli /backstores/${backend} create ${lun} ${name} ${size}
    #Fixme set attribute for backstores
    for attr in ${attrs}; do
      echo "set attribute ${attr}"
      targetcli /backstores/${backend}/${lun} set attribute ${attr}
    done

  fi
  for target in ${targets}; do
    targetcli /iscsi delete ${target}
    targetcli /iscsi create ${target}
    targetcli /iscsi/${target}/tpg1/luns create /backstores/${backend}/${lun}
    for c in ${clients}; do
      targetcli /iscsi/${target}/tpg1/acls create ${c}
    done
  done
  targetcli / ls
  targetcli saveconfig
  targetcli exit

}

wiscsi_create_block_scsi() {
  #targetcli script and targetcli can not run meanwhile
  #create one block device backend
  #  local targeta="iqn.2016-06.share.server:scsi-debug"
  #  modprobe -r scsi_debug
  #  modprobe scsi_debug dev_size_mb=3000
  #  dev=$(lsscsi | grep scsi | awk '{ print $6 }')
  #  pvcreate ${dev}
  #  vgcreate vg ${dev}
  #  #  lvcreate iscsi_disk01 -l 100%FREE -n iscsi_lv01
  #  lvcreate -L 2G -n lv vg
  #  dev=/dev/vg/lv
  local file=/tmp/loopbackfile.img
  dd if=/dev/zero of=$file bs=100M count=20
  local loopdev=$(losetup -f)
  losetup $loopdev $file
  wiscsi_create -t "iqn.2016-06.block.server:4g" -b block -c "$clienta $clientb" -l block1 -n $loopdev

  #losetup -d $loopdev

}
wiscsi_create_one() {
  local targets name lun clients backend size attrs
  size=3g
  targets="iqn.2016-06.one.server:one-a"
  backend="fileio"
  clients="$clienta $clientb"
  lun="disk1"
  name=/home/iscsi/onex.img
  wiscsi_create "$@"

}

wiscsi_create_share() {
  local targets name lun clients backend size attrs
  size=10g
  targets="iqn.2016-06.share.server:10g-a iqn.2016-06.share.server:10g-b"
  backend="fileio"
  clients="$clienta $clientb"
  lun="disk2"
  name=/home/iscsi/sharex.img
  wiscsi_create "$@"

}

wiscsi_create_share_old() {
  #targetcli script and targetcli can not run meanwhile
  #create two shared target and can be accessed by two client
  local targeta=iqn.2016-06.share.server:4g-a
  local targetb=iqn.2016-06.share.server:4g-b
  targetcli /backstores/fileio create disk0 /home/iscsi/share4g.img
  targetcli /iscsi create ${targeta}
  targetcli /iscsi create ${targetb}
  targetcli /iscsi/${targeta}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${targetb}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${targeta}/tpg1/acls create ${clienta}
  targetcli /iscsi/${targeta}/tpg1/acls create ${clientb}
  targetcli /iscsi/${targetb}/tpg1/acls create ${clienta}
  targetcli /iscsi/${targetb}/tpg1/acls create ${clientb}
  targetcli / ls
  targetcli saveconfig
  targetcli exit

  systemctl restart target iscsi iscsid

}

wiscsi_discover() {

  local usage="usage: -t <targets> -n hostname -f filter"
  local targets name filter OPT OPTARG OPTIND

  port=3260
  #  name=10.66.8.105
  name=127.0.0.1
  targets=$(targetcli /iscsi ls depth=1 | grep iqn | awk '{print $2}')
  while getopts 'f:t:n:h' OPT; do
    case $OPT in
    t) targets="$OPTARG" ;;
    n) name="$OPTARG" ;;
    f) filter="$OPTARG" ;;
    h) echo -e ${usage} ;;
    ?) echo -e ${usage} ;;
    esac
  done

  if [[ "$filter" != "" ]]; then
    targets=$(echo -e "$targets" | grep "$filter"ef)
  fi

  echo "iscsiadm -m discovery -t st -p $name"
  local opa=("-l" "-u" "-o delete")
  for o in "${opa[@]}"; do
    for target in ${targets}; do
      echo "iscsiadm -m node -T ${target}  -p $name:$port $o"
      #    echo "iscsiadm -m node -T ${target}  -p $name:$port -l"
      #    echo "iscsiadm -m node -T ${target}  -p $name:$port -u"
      #    echo "iscsiadm -m node -T ${target}  -p $name:$port -o delete"
    done
  done

}

wiscsi_restart() {
  systemctl restart target iscsi iscsid
}
#libiscsi windows guest inititorname
#uuid=ea78071a-f6e4-4347-8077-9cb9f7959e66
#uuid=ea78071a-f6e4-4347-8077-9cb9f7959e88
#iqn.2008-11.org.linux-kvm:${uuid}
#wiscsi $@
