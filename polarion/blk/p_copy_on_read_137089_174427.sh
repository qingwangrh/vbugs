
[ -e /home/images ] || mkdir -p /home/images

qemu-img create -f raw /home/images/remote.img 1G
qemu-img create -f qcow2 /home/images/local.qcow2 -b 'json: {"file.driver":"ssh", "file.host":"127.0.0.1","file.path":"/home/images/remote.img","file.host_key_check":"no" }'
#first
qemu-img map /home/images/local.qcow2 --output=json
time qemu-io --image-opts driver=copy-on-read,file.driver=qcow2,file.file.driver=file,file.file.filename=/home/images/local.qcow2 -c 'read 0 10M'
#second faster than first
qemu-img map /home/images/local.qcow2 --output=json
time qemu-io --image-opts driver=copy-on-read,file.driver=qcow2,file.file.driver=file,file.file.filename=/home/images/local.qcow2 -c 'read 0 10M'