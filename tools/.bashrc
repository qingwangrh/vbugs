# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi
alias wtree='tree --charset ASCII'
alias ll='ls -la'
alias ls='ls --color=auto'
alias findp='ps  aux|grep'
alias lsd="ls -d */|sed 's/\// /g'|xargs ls -d --color"
alias lsf="ls -p|grep [^/]$|xargs ls -lh --color"
#alias lsd="ls -d */|sed 's/\///g'"
alias wfind='find ./ -not \( -name .svn -a -prune \) -name'
#alias wssh='ssh -o StrictHostKeyChecking=no '
alias wmqing='if ! rpm -qa|grep nfs-utils > /dev/null;then yum install nfs-utils -y;fi;mkdir -p /home/vbugs;if [ ! -e /home/vbugs/setup.sh ];then mount 10.66.8.105:/home/vbugs /home/vbugs; else echo "already mount"; fi'
alias wconsole='console -l qinwang -M conserver-01.eng.pek2.redhat.com '
alias wversion="{ cat /etc/redhat-release;uname -r;rpm -qa|grep -E kvm-common-\"(rhev|[0-9])\";rpm -qa|grep seabios-[0-9];rpm -qa|grep edk2;readlink /home/kvm_autotest_root/iso/windows/virtio-win-latest-prewhql.iso; } > /tmp/wversion.txt;cat /tmp/wversion.txt"
alias wproxy="export https_proxy=http://squid.corp.redhat.com:3128"
if [[ -f /usr/bin/vim ]]; then
  alias vi=vim
fi

GREPCOL=""
if uname -a | grep sparc; then
  function sgrep() {
    grep -n "$*" * | grep -v '\.svn/' | grep "$*"
  }

  export TERM=xterm-color
else
  GREPCOL=--color=auto
  function sgrep() {
    echo $*
    grep -r -n -i "$*" ./ | grep -v '\.svn/' | grep --color=auto -i "$*"
  }

  if grep --help >/dev/null | grep "exclude-dir"; then
    GREP_OPTIONS="--exclude-dir=\.svn"
    export GREP_OPTIONS
  fi

fi

wmyip() { ip addr | grep inet | grep '10\.' | awk '{print $2}' | cut -f 1 -d '/'; }

wscreen() {
  echo "usage:create screen session"
  if (($# < 1)); then
    idx=1
  else
    idx=$1
  fi

  echo "wscreen $idx"
  name="screen${idx}"

  if screen -S $name -ls; then
    echo "Quit exist $name"
    screen -X -S $name quit
  fi

  if [[ -d workspace/job-results ]]; then
    cd workspace/job-results
    screen -dmS $name python3 -m http.server 800$idx
    cd -
  else
    screen -dmS $name python3 -m http.server 800$idx
  fi
  screen -S $name -ls
  local ip=$(ip addr | grep inet | grep "10\." | awk '{print $2}' | cut -f 1 -d "/")
  #local ip=`hostname -I|awk '{print $1}'`
  echo "http://$ip:800$idx"

}

wdu() {
  if [[ -n $1 ]]; then
    d=$1
  else
    d=1
  fi
  echo "du --max-depth=$d -h"
  du --max-depth=$d -h
}

wvncserver() {
  if [ "x$1" == "x" ]; then
    VNC_ID=86
  else
    VNC_ID=$1
  fi
  if [ "x$2" == "x" ]; then
    VNC_RES=1600x920
  else
    VNC_RES=$2
  fi
  cmd="vncserver -kill :${VNC_ID};  vncserver :${VNC_ID} -SecurityTypes None -geometry ${VNC_RES}"
  echo "$cmd"
  eval $cmd
}

wview() {
  echo "Usage: wview host port protocol"
  host=ibm
  port=$1
  protocol=vnc
  if (($# > 1)); then
    host=$1
    port=$2
    if [[ x"$3" != "x" ]]; then
      protocol=spice
    fi

  fi
  cmd="remote-viewer $protocol://$host:$port"
  echo "$cmd"
  ${cmd}
}

wenv() {
  local target
  echo "cp host gitconfig bashrc to target host"
  for target in "$@"; do
    echo "==>$target"
    scp -o StrictHostKeyChecking=no ~/.bashrc $target:~/
    scp -o StrictHostKeyChecking=no ~/.gitconfig $target:~/
    scp -o StrictHostKeyChecking=no /etc/hosts $target:/etc/hosts
  done

}

wsshx() {

  if (($# < 2)); then
    echo "Usage wssh host cmd"
    return
  fi
  host=$1
  shift
  cmd="$@"
  echo "cmd=$cmd"
  #"*IDENTIFICATION HAS CHANGED*" { send "rm -rf ~/.ssh/known_hosts\r";spawn ssh root@${host};exp_continue }
  expect <<EOF
    set timeout 3
    set rmflag 0
    spawn ssh -o "StrictHostKeyChecking=no" root@${host}
    expect {
    	"*IDENTIFICATION HAS CHANGED" { exit 168 }
        "*yes/no" { send "yes\r";exp_continue }
        "*password:" { send "kvmautotest\r"; }
	#-re "\[\$\#\] ?$" { send "${cmd}\r";send "exit\r";expect eof; }
	-re "\[\$\#\] ?$" { send "#\r"; }
    }
    
    expect -re ".*\[\$#\] ?$"
    send "${cmd}\rexit\r"
    #expect -re ".*\[\$#\]"
    #send "exit\r"
    expect eof
EOF
}

wclear() {
  if (($# < 1)); then
    echo "Usage wclear host"
    return
  fi
  echo "clean bashrc,auto login on $1"
  host=$1
  #   wsshx ${host} "rm ~/.bashrc .ssh/* -rf"
  wsshx ${host} "sed -i -e '/PS1=/d' -e '/PROMPT_COMMAND=/d' ~/.bashrc;yes|rm ~/.ssh/authorized_keys;tail -n 8 ~/.bashrc"
  #wsshx ${host} "tail -n 8 ~/.bashrc;ls ~/.ssh/"
}

winit() {
  echo "create passwordless env for $1"
  host=$1
  if (($# < 1)); then
    echo "Usage winit host"
    return
  fi
  id_rsa="-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAuub8XfoSYyNtTG/w7L7PJSKIUEWlE/r/ZqPxgkzznR13vNUHn8N2
thzqCyZs/s1KH+DMGqDydLqNJwirPYICnYU5TJPPIU7AWL098odRVXIP6wAxd9Js6PtzMm
omM52J1TlfSNv9Y3G5Sg06J6IRGvJ+asTlWr/JRSMjAirNIqGbuv+lwE6hDMyQMVlJ6zrZ
h5o7c9UN/+b0QQG/jAGU2NXGeZ34hkSas+DrBkl+9j4T6j171KhPTrbr5kie7MQ5oiQ9jW
sxRqbqbLK9VztE/bNqkhMZsW+mep2PJ6vsIQH/lNw3TDA0Sz6hBH0yQAI8F3cn8E+uf0is
HFg8jQxgWwAAA9C+SFhEvkhYRAAAAAdzc2gtcnNhAAABAQC65vxd+hJjI21Mb/Dsvs8lIo
hQRaUT+v9mo/GCTPOdHXe81Qefw3a2HOoLJmz+zUof4MwaoPJ0uo0nCKs9ggKdhTlMk88h
TsBYvT3yh1FVcg/rADF30mzo+3MyaiYznYnVOV9I2/1jcblKDTonohEa8n5qxOVav8lFIy
MCKs0ioZu6/6XATqEMzJAxWUnrOtmHmjtz1Q3/5vRBAb+MAZTY1cZ5nfiGRJqz4OsGSX72
PhPqPXvUqE9OtuvmSJ7sxDmiJD2NazFGpupssr1XO0T9s2qSExmxb6Z6nY8nq+whAf+U3D
dMMDRLPqEEfTJAAjwXdyfwT65/SKwcWDyNDGBbAAAAAwEAAQAAAQBXyTJz+Yc1ZWhq5JEm
waCN8qBQA8Y7kkLvtMU0zGwIOdUJro18LtTNSNttDUlYjJfqTS3QvBPlW9H8qYe0xiHwVq
jJHQvGuzSA+bHk/kXnekGbwWV6wC1DaQd8gHsc9zvMGLx2fk2PrdS3wWq1PtwF6iwSfhS0
ASzJ+mzxEaV0Q+D7S/Pd/YvAQEcf0uesJky+fW3VLJc0PlPy6QRWirX63/OMc6Ohc/NYGB
QhnqxVbFqQgCOCQ2vnk36BCERloh6MApkZmRPec9w8Rg0Av8mNQaHp7aVxd2knWZZ1Bm2Y
OKPn8ZtA/1L+AlfUpmDJHBf3xfNdY8wmsMHjTL1yNvJRAAAAgQDRcJxTFpp+FD/YSPnAx3
0Q4s7QMKt2F7ZGjuClD5FUCCsEeeE+yVlu9igbkOJy3ex0Lxv0VWVIMyoE5imysdJAmoMO
GeQy4kSg8EbFWQlIQePsAlYqZcZ/CA01pnW4OI04/QSVAlfTdj4fVH66rD/2kp+8em5bCH
q2rbdk+QZKWAAAAIEA9ea8C5mtBjeYkz7yvPoFTSitZJZLiOhhMLWi6I0h80UbQmAqGxF6
IVF2yTT/B55tVU6Wq07AuquOkvPl/pHtqOEryGlXNHR5AVRWVeHycfrND67jIEUM5svMnU
Rzz2vGzyq98rAIReBgIza4UIA4tjd5SnAT/cdu0FRED7RaUTUAAACBAMKT+ClP/Gx2IMgz
1b87YFq/aY01gZDtfpwp4DfjFmqO59IwPydyodD1EsoyZ6QaFZKKMplZBVG2zmlgPY5TTI
8jqWysTTn8HRa3+EMkNUtknAMRf2LNKqgkBgGNBOTINSZ2jBYdjoH5pzRPfSXh8buZ2b7N
PBfjo24ivZf9Ky1PAAAAGnJvb3RAbG9jYWxob3N0LmxvY2FsZG9tYWlu
-----END OPENSSH PRIVATE KEY-----"
  id_rsa_pub="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC65vxd+hJjI21Mb/Dsvs8lIohQRaUT+v9mo/GCTPOdHXe81Qefw3a2HOoLJmz+zUof4MwaoPJ0uo0nCKs9ggKdhTlMk88hTsBYvT3yh1FVcg/rADF30mzo+3MyaiYznYnVOV9I2/1jcblKDTonohEa8n5qxOVav8lFIyMCKs0ioZu6/6XATqEMzJAxWUnrOtmHmjtz1Q3/5vRBAb+MAZTY1cZ5nfiGRJqz4OsGSX72PhPqPXvUqE9OtuvmSJ7sxDmiJD2NazFGpupssr1XO0T9s2qSExmxb6Z6nY8nq+whAf+U3DdMMDRLPqEEfTJAAjwXdyfwT65/SKwcWDyNDGBb"
  wsshx ${host} "echo"
  ret=$?
  if [[ ${ret} == 168 ]]; then
    rm -rf /root/.ssh/known_hosts
  fi
  wsshx ${host} "mkdir -p ~/.ssh;echo '${id_rsa}' > ~/.ssh/id_rsa;echo '${id_rsa_pub}' > ~/.ssh/id_rsa.pub;yes|cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys;chmod 600 ~/.ssh/*;"
  [[ $? == 0 ]] && wenv ${host}
}

wgitupdate() {
  local REPLY
  {
    echo -n "Are you sure start to git update[y/n]: "
    read
    echo "You typed ${REPLY}"
  }
  if [[ "${REPLY}" != "y" ]]; then
    return 1
  fi
  git st ./
  git stash list
  git stash
  git stash list
  git pull origin master
  #keep change
  #git stash apply
  git stash pop
  git stash list
}

wgitcp() {
  local usage="Usage: wgitcp [-All/-Track]  -d dst -f [files]"
  local OPT OPTARG OPTIND
  local mode="tracked"
  local target files
  while getopts 'd:f:ath' OPT; do
    case $OPT in
    f) files="$OPTARG" ;;
    d) target="$OPTARG" ;;
    a) mode="all" ;;
    t) mode="tracked" ;;
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

  if [ "X$target" == "X" ]; then
    echo -e ${usage}
    return 1
  fi

  if [[ "X$files" == "X" ]]; then
    echo "Checking $mode"
    if [[ "$mode" == "all" ]]; then
      files=$(git status -s | awk '{print $2}')
    else
      files=$(git status -s --untracked-files=no | awk '{print $2}')
    fi
  fi
  if [[ "X$files" == "X" ]]; then
    echo "Nothing to do"
    return 1
  fi
  echo -e "$files"
  #  cmd="echo -e $files |xargs -I {} scp  {} ${target}/{}"
  #  echo "${cmd}"
  total=0
  for f in $files; do
    cmd="scp ${f} ${target}/${f}"
    echo "$cmd"
    yes | $cmd
    let total=total+1
  done
  echo "total:$total"

}

wloop() {
  usage="wloop start end cmd"
  local cmd n end start=$1

  let end=$1+$2
  shift
  shift
  cmd="$@"
  for ((n = $start; n < $end; n++)); do
    echo ""
    echo "$(date)- - - - - - - - - - -$n"
    #replace @@ with index
    new_cmd="${cmd//@@/$n}"
    echo -e "$new_cmd\n"
    #/bin/sh -c "$new_cmd"
    eval "$new_cmd"
  done
}

wloopl() {
  local usage="wloopl file cmd"
  local Line file=$1
  shift
  local cmd="$@"
  if [[ "x$cmd" == "x" ]]; then
    echo -e ${usage}
    return 1
  fi

  cat ${file} | while read Line; do
    echo "- - - - - - - - - - -${Line}"
    new_cmd="${cmd//@@/${Line}}"
    echo -e "$new_cmd\n"
    #/bin/sh -c "$new_cmd"
    eval "$new_cmd"
  done

}

wsetup() {
  echo "setup the basic env"
  if [[ "x$1" == "x" ]]; then
    echo "setup"
    mkdir -p {/home/vbugs,/home/rexports}
    mount qing:/home/exports /home/rexports
    mount qing:/home/vbugs /home/vbugs
  elif [[ "$1" == "-d" ]]; then
    echo "clean"
    umount /home/vbugs
    umount /home/rexports
  fi

}

wyumsed() {
  local rp
  if [[ "x$1" == "x" ]]; then
    [[ -f /etc/yum.repos.d/beaker-Server.repo ]] && file=beaker-Server.repo || file=beaker-BaseOS.repo
    if cat /etc/yum.repos.d/${file} | egrep "RHEL-[0-9.]{3,}"; then
      rp=$(cat /etc/yum.repos.d/${file} | egrep -o "RHEL-[0-9.]{3,}")
    fi
  else
    rp=$1
  fi

  if [[ "x${rp}" == "${rp}" ]]; then
    echo "Do nothing"
  fi
  echo "/etc/yum.repos.d/${file} ${rp}"
  cmd="sed -i -e 's/${rp}-.*\../latest-${rp}/g' /etc/yum.repos.d/*.repo"
  echo "$cmd"
}

wmount() {
  [[ -d /mnt/iso ]] || mkdir -p /mnt/iso
  [[ -d /mnt/bug_nfs ]] || mkdir -p /mnt/bug_nfs
  [[ -d /mnt/gluster ]] || mkdir -p /mnt/gluster
  [[ -d /mnt/logs ]] || mkdir -p /mnt/logs
  [[ -d /mnt/exlogs ]] || mkdir -p /mnt/exlogs
  echo "mount.glusterfs gluster-virt-qe-01.lab.eng.pek2.redhat.com:/gv0  /mnt/gluster"
  echo "mount 10.73.194.27:/vol/s2kvmauto/iso  /mnt/iso"
  echo "mount 10.73.194.27:/vol/s2kvmauto/iso  /home/kvm_autotest_root/iso"
  echo "mount 10.73.194.27:/vol/S4/virtlablogs /mnt/logs"
  echo "mount 10.73.32.21:/kvmqelogs /mnt/exlogs"
  echo "mount qing:/home/exports /home/rexports"
  echo "mount 10.73.194.27:/vol/s2images294422  /mnt/bug_nfs/"
  echo "http://fileshare.englab.nay.redhat.com/pub/section2/images_backup"
  echo " ln -s workspace/var/lib/avocado/data/avocado-vt/virttest/test-providers.d/downloads/io-github-autotest-qemu tp-qemu; ln -s workspace/avocado-vt avocado-vt; ln -s workspace/var/lib/avocado/data/avocado-vt/backends/qemu/cfg output-cfg;"
  echo "export https_proxy=http://squid.corp.redhat.com:3128"
}

wbug() {
  local target_dir

  if (($# < 2)); then
    echo -e "Usage: wbug 123 dir1 dir2"
    return 1
  fi

  if ! mount | grep '/mnt/bug_nfs' >/dev/null; then
    [[ -d /mnt/bug_nfs/ ]] || mkdir -p /mnt/bug_nfs/
    echo "mount 10.73.194.27:/vol/s2images294422  /mnt/bug_nfs/"
    if mount 10.73.194.27:/vol/s2images294422 /mnt/bug_nfs/; then
      target_dir="${target_dir} /mnt/bug_nfs/qbugs/"
    fi
  else
    echo "already mount /mnt/bug_nfs/"
    target_dir="${target_dir} /mnt/bug_nfs/qbugs/"
  fi

  bugid=$1
  shift
  log_dir="$@"

  T=$(date "+%F")
  echo "$log_dir"
  for d in $target_dir; do
    bugdir=$d/${bugid}/${T}/
    echo "cp to ${bugdir}"
    mkdir -p ${bugdir}
    for l in $log_dir; do
      [[ "x$l" != "x" ]] && cp -rf $l ${bugdir}
    done
    if echo "$d" | grep rexports; then
      echo "http://10.66.8.105:8000/qbugs/$bugid/$T"
    elif echo "$d" | grep bug_nfs; then
      echo "http://fileshare.englab.nay.redhat.com/pub/section2/images_backup/qbugs/$bugid/$T"
    else
      echo "nothing"
    fi
  done

}

wlog_clean() {
  #    log_dir=/home/rexports/qlogs/
  log_dir=/mnt/bug_nfs/qlogs/
  log_id=$1
  if [[ "x$1" != "x" ]]; then
    echo "clean ${log_dir}/${log_id}"
    [[ -d ${log_dir}/${log_id}/test-results ]] || return 0

    cd ${log_dir}/${log_id}/test-results
    for sublog in $(ls -d */); do
      if ((${#sublog} > 5)); then
        echo "enter ${sublog}"
        cd ${sublog}
        if tail -n 3 debug.log | grep -E " PASS "; then
          echo "Pass ${sublog}"
          rm -rf screendumps*
          find ./ -size +2M -exec rm {} \;
        else
          echo "Not Pass ${sublog}"
        fi
        cd -
      fi
    done
    cd ${log_dir}
  fi

}

wlog() {

  local target_dir

  if (($# < 2)); then
    echo "$# : Usage: wlog logdir alias"
    return 1
  fi

  if ! mount | grep '/mnt/bug_nfs' >/dev/null; then
    [[ -d /mnt/bug_nfs ]] || mkdir -p /mnt/bug_nfs
    echo "mount 10.73.194.27:/vol/s2images294422  /mnt/bug_nfs/"
    if ! mount 10.73.194.27:/vol/s2images294422 /mnt/bug_nfs/; then
      echo "mount 10.73.194.27:/vol/s2images294422  /mnt/bug_nfs/ failed"
      return 1
    fi
  fi
  target_dir="${target_dir} /mnt/bug_nfs/qlogs/data/"

  T=$(date "+%Y%m%d")
  log_name=$(echo "$2" | tr -d " ")

  for log_dir in ${target_dir}; do
    if [[ ! -d ${log_dir} ]]; then
      echo "The mounted folder need data and history"
      return 1
    fi

    log_id=$1
    if [[ -d ${log_dir}/${log_id} ]]; then
      echo "exist ${log_dir}/${log_id},skip cp..."
    else
      echo "cp -rf ${log_id} ${log_dir}"
      cp -rf ${log_id} ${log_dir}
    fi

    #create soft link
    stamp_link="${log_name}_${T}"
    echo "generate wversion.txt"
    wversion
    yes | cp -rf /tmp/wversion.txt ${log_dir}/${log_id}/wversion_${T}.txt

    echo "create soft link:${log_dir}/${log_id} ${log_name}"
    touch ${log_dir}/${log_id}/${stamp_link}

    ln -sf ${log_id} ${log_name}
    cd ${log_dir}../
    [[ -L ${log_name} ]] && echo "delete exist link ${log_name}" && rm -rf ${log_name}
    ln -s data/${log_id} ${log_name}
    ls -l ${log_name}
    cd - >/dev/null
    echo "create history soft link:${log_dir}/${log_id} ${stamp_link}"
    cd ${log_dir}../history/
    [[ -L ${stamp_link} ]] && echo "delete exist link ${stamp_link}" && rm -rf ${stamp_link}
    ln -sf ../data/${log_id} ${stamp_link}
    ls -l ${stamp_link}
    cd - >/dev/null
  done

  echo "http://fileshare.englab.nay.redhat.com/pub/section2/images_backup/qlogs/${log_name}"

  if [[ "x$3" != "x" ]]; then
    wlog_clean ${log_name}
  fi
}

wrdesktop() {
  echo "create windows remote desktop"
  rdesktop -g 1600x900 10.73.74.245 -u administrator -p Assentor01
}

wqmp_loop() {
  echo "wloop_qmp start end action"
  exec 3<>/dev/tcp/localhost/5955
  echo -e "{'execute':'qmp_capabilities'}" >&3
  read response <&3
  echo $response

  unset n
  start=$1
  let end=$1+$2
  shift
  shift
  cmd="$@"
  # you need put ; for you multiline command
  cmd=$(echo $cmd | tr -s "\n" ";")
  echo $cmd

  for ((n = $start; n < $end; n++)); do
    echo ""
    #    echo "$(date)- - - - - - - - - - -$n"
    #replace @@ with index
    new_cmd="${cmd//@@/$n}"

    OLD_IFS="$IFS"
    IFS=";"

    myarray=($new_cmd)

    for mvar in "${myarray[@]}"; do
      var=$(echo "$mvar" | grep -o "[^ ]\+\( \+[^ ]\+\)*")
      if [[ "x$var" != "x" ]]; then
        if echo "$var" | grep ":" >/dev/null; then
          echo "$var"
          echo -e "$var" >&3
          read response <&3
          echo "$response"
        else
          eval "$var"
        fi
      fi
    done
    IFS="$OLD_IFS"

    sleep 1

  done
}

wqmp_exec() {
  wqmp_loop 1 1 "$@"
}

export PATH=$PATH:/usr/local/bin
export VTE="./var/lib/avocado/data/avocado-vt/backends/qemu/cfg/tests-example.cfg"

#PS1='[${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;33m\]\w\[\033[00m\]]\$ '
#PROMPT_COMMAND='printf "\033]0;%s:%s\007" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'

PS1="\[\033[01;32m\]\u@\h \[\033[01;33m\]\w\\[\033[00m\] \$ "
PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}  \007"'

cd /home
#ulimit -c unlimited
