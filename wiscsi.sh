#iscsi relevant operations

clienta="iqn.1994-05.com.redhat:clienta"
clientb="iqn.1994-05.com.redhat:clientb"

wiscsi_deploy() {
  #deploy targetcli
  mkdir -p /etc/target/pr
  mkdir -p /home/iscsi/
  yum install targetcli -y
  systemctl enable target;systemctl start target
  systemctl enable targetcli
  systemctl start targetcli
  dd if=/dev/zero of=/home/iscsi/share4g.img bs=1M count=4096
  targetcli clearconfig confirm=True
}

wiscsi_create(){
  echo "dev/file target clients"
  dev=$1
  target=$2
  shift
  shift
  clients="$@"

}

wiscsi_create_block_scsi() {
  #targetcli script and targetcli can not run meanwhile
  #create one block device backend
  local targeta="iqn.2016-06.share.server:scsi-debug"
  modprobe -r scsi_debug; modprobe scsi_debug dev_size_mb=3000
  dev=`lsscsi |grep scsi|awk '{ print $6 }'`
  pvcreate ${dev}
  vgcreate vg ${dev}
#  lvcreate iscsi_disk01 -l 100%FREE -n iscsi_lv01
  lvcreate -L 2G -n lv vg
  dev=/dev/vg/lv
  targetcli /backstores/block create disk0 $dev
  targetcli /iscsi create ${targeta}
  targetcli /iscsi/${targeta}/tpg1/luns create /backstores/block/disk0
  targetcli /iscsi/${targeta}/tpg1/acls create ${clienta}
  targetcli /iscsi/${targeta}/tpg1/acls create ${clienta}

  targetcli / ls
  targetcli saveconfig
  targetcli exit

  systemctl restart target iscsi iscsid

}

wiscsi_create_share() {
  #targetcli script and targetcli can not run meanwhile
  #create two shared target and can be accessed by two client
  local targeta=iqn.2016-06.share.server:4g-a
  local nameb=iqn.2016-06.share.server:4g-b
  targetcli /backstores/fileio create disk0 /home/iscsi/share4g.img
  targetcli /iscsi create ${targeta}
  targetcli /iscsi create ${nameb}
  targetcli /iscsi/${targeta}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${nameb}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${targeta}/tpg1/acls create iqn.1994-05.com.redhat:clienta
  targetcli /iscsi/${targeta}/tpg1/acls create iqn.1994-05.com.redhat:clientb
  targetcli /iscsi/${nameb}/tpg1/acls create iqn.1994-05.com.redhat:clienta
  targetcli /iscsi/${nameb}/tpg1/acls create iqn.1994-05.com.redhat:clientb
  targetcli / ls
  targetcli saveconfig
  targetcli exit

  systemctl restart target iscsi iscsid

}

wiscsi_discover() {
  local OPTIND opt
  port=3260
  host=10.66.8.105
  target=iqn.2016-06.local.server:sas
  echo "$0 -l -t <target> -h host"
  while getopts ":t:h:" opt; do
    case $opt in
#    l)
#      cmd="iscsiadm -m discovery -t st -p $host"
#      ;;
    t)
      echo "target: $OPTARG"
      target="$OPTARG"
      ;;
    h)
      echo "host: $OPTARG"
      host="$OPTARG"
      ;;
    ?)
      echo "unknown parameter"
      return 1
      ;;
    esac
  done

  echo "iscsiadm -m discovery -t st -p $host"
  echo "iscsiadm -m node -T ${target}  -p $host:$port -l"
  echo "iscsiadm -m node -T ${target}  -p $host:$port -u"
  echo "iscsiadm -m node -T ${target}  -p $host:$port -o delete"

}

#libiscsi windows guest inititorname
#uuid=ea78071a-f6e4-4347-8077-9cb9f7959e66
#uuid=ea78071a-f6e4-4347-8077-9cb9f7959e88
#iqn.2008-11.org.linux-kvm:${uuid}
#wiscsi $@
