
echo "sg_persist device key"
key=123abc
dev=$1
if [[ "x$2" != "x" ]];then
  key=$2
fi


echo "1:register-key"
sg_persist --no-inquiry -v --out --register-ignore --param-sark ${key} ${dev}
echo "2:read-key"
sg_persist --no-inquiry --in -k ${dev}
echo "3:reserve"
sg_persist --no-inquiry -v --out --reserve --param-rk ${key} --prout-type 5 ${dev}
echo "4:read-reservation"
sg_persist --no-inquiry --in -r ${dev}
echo "5:release"
sg_persist --no-inquiry -v --out --release --param-rk ${key} --prout-type 5 ${dev}
echo "6:read-reservation"
sg_persist --no-inquiry --in -r ${dev}
echo "7:cancel-register"
sg_persist --no-inquiry -v --out --register --param-rk ${key} --prout-type 5 ${dev}
echo "8:read-key"
sg_persist --no-inquiry --in -k ${dev}

