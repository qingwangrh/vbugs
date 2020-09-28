#iscsi relevant operations

wiscsi(){

port=3260
host=10.66.8.105
target=iqn.2016-06.local.server:sas
while getopts ":l:t:h:" opt
do
    case $opt in
        l) 
        cmd="iscsiadm -m discovery -t st -p $host"
        ;;
        t) echo "target: $OPTARG"
	target="$OPTARG"
        ;;
        h) echo "host: $OPTARG"
        host="$OPTARG"
        ;;
        ?) echo "unknown parameter"
        exit 1 ;;
    esac
done
if [[ "x$cmd" != "x" ]];then
 $cmd
else
 echo "iscsiadm -m discovery -t st -p $host"
 echo "iscsiadm --mode node --targetname ${target}  --portal $host:$port --login"
 echo "iscsiadm --mode node --targetname ${target}  --portal $host:$port --logout"
 echo "iscsiadm --mode node --targetname ${target}  --portal $host:$port -o delete"
fi
}

wiscsi $@ 
