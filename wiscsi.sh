#iscsi relevant operations

wiscsi_deploy() {
  #deploy targetcli
  mkdir -p /etc/target/pr
  mkdir -p /home/iscsi/
  yum install targetcli -y
  systemctl enable targetcli
  systemctl start targetcli
  dd if=/dev/zero of=/home/iscsi/share4g.img bs=1M count=4096
  targetcli clearconfig confirm=True
}

wiscsi_create() {
  #targetcli script and targetcli can not run meanwhile
  #create two shared target and can be accessed by two client
  namea=iqn.2016-06.share.server:4g-a
  nameb=iqn.2016-06.share.server:4g-b
  targetcli /backstores/fileio create disk0 /home/iscsi/share4g.img
  targetcli /iscsi create ${namea}
  targetcli /iscsi create ${nameb}
  targetcli /iscsi/${namea}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${nameb}/tpg1/luns create /backstores/fileio/disk0
  targetcli /iscsi/${namea}/tpg1/acls create iqn.1994-05.com.redhat:clienta
  targetcli /iscsi/${namea}/tpg1/acls create iqn.1994-05.com.redhat:clientb
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
