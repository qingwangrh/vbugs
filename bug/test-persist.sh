
echo "sg_persist $@"

echo "1:register-key"
sg_persist --no-inquiry -v --out --register-ignore --param-sark 123aaa "$@"
echo "2:read-key"
sg_persist --no-inquiry --in -k "$@"
echo "3:reserve"
sg_persist --no-inquiry -v --out --reserve --param-rk 123aaa --prout-type 5 "$@"
echo "4:read-reservation"
sg_persist --no-inquiry --in -r "$@"
echo "5:release"
sg_persist --no-inquiry -v --out --release --param-rk 123aaa --prout-type 5 "$@"
echo "6:read-reservation"
sg_persist --no-inquiry --in -r "$@"
echo "7:cancel-register"
sg_persist --no-inquiry -v --out --register --param-rk 123aaa --prout-type 5 "$@"
echo "8:read-key"
sg_persist --no-inquiry --in -k "$@"

