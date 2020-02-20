# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
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
alias wssh='ssh -o StrictHostKeyChecking=no '
alias wmountqing='mkdir -p /home/rworkdir;mount 10.66.8.105:/home/workdir /home/rworkdir'
alias wconsole='console -l qinwang -M conserver-01.eng.pek2.redhat.com '
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

wscreen()
{
screen -S kar$1 python3 -m http.server 800$1
}
wdu(){
	if [[ -n $1 ]];then
	d=$1
	else
	d=1
	fi
	echo "du --max-depth=$d -h"
	du --max-depth=$d -h
	}
	
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;33m\]\w\[\033[00m\] \$ '
PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}  \007"'
wvncserver() {
	if [ "x$1" == "x" ]; then
		VNC_ID=86
	else
		VNC_ID=$1
	fi
	if [ "x$2" == "x" ]; then
		VNC_RES=1600x1000
	else
		VNC_RES=$2
	fi
	cmd="vncserver -kill :${VNC_ID};  vncserver :${VNC_ID} -SecurityTypes None -geometry ${VNC_RES}"
	echo "$cmd"
	eval $cmd
}

wremote() {
	echo "Usage: wremote host port"
	host=ibm
	port=$1
	if (($# > 1)); then
		host=$1
		port=$2

	fi
	cmd="remote-viewer vnc://$host:$port"
	echo "$cmd"
	${cmd}
}

wenv() {
	for target in $@;do
	echo "==>$target"
	scp ~/.bashrc $target:~/
	scp /etc/hosts $target:/etc/hosts
	done


}

wkarsync(){
	#wgitsync repo target files
	if (($# < 2)); then
		echo "miss parameter"
		return 1
	fi
	wgitsync $@ 
	
}
wgitsync() {
	echo -e "Usage: wgitsync repo target. \nExample: wgitsync tp-qemu kar-run"
	echo "$#"
	if (($# < 1)); then
		echo "miss parameter"
		return 1
	fi
	repo=$1
	case $1 in
	"a")
		repo="avocado-vt"
		;;
	"t")
		repo="tp-qemu"
		;;
	"k")
		repo="kar"
		;;
	esac
	echo "${repo}"

	target=kar-run 
	if [[ "X$2" != "X" ]];then
		target=$2
	fi
	shift
	shift
	files="$@"
	if [[ "X$files" == "X" ]]; then
		echo "Checking"
		cd ${repo}
		git status -s
		files=$(git status -s ./ | cut -f 3 -d " ")
		cd -
	fi
	if [[ "X$files" == "X" ]]; then
		echo "Nothing to do"
		return 1
	fi

	total=0
	for f in $files; do
		cmd="cp ${repo}/${f} /workdir/${target}/${repo}/${f}"
		echo "$cmd"
		yes | $cmd
		let total=total+1
	done
	echo "total:$total"

}

wloop() {
	echo "wloop start end action"
	unset n
	start=$1
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

	unset n
	f=$1
	shift

	cmd="$@"
	if [[ "x$cmd" == "x" ]]; then
		return
	fi

	data=$(cat ${f})
	echo "$data"
	for n in $data; do
		echo "- - - - - - - - - - -$n"
		new_cmd="${cmd//@@/$n}"
		echo -e "$new_cmd\n"
		#/bin/sh -c "$new_cmd"
		eval "$new_cmd"
	done

}
wsetup(){
	if [[ "x$1" == "x" ]];then
		echo "setup"
	mkdir -p {/home/workdir/exports,/workdir,/workdir/rworkdir}
	mount -o bind /home/workdir /workdir
	mount qing:/home/exports /workdir/exports
	mount qing:/home/workdir /workdir/rworkdir
        elif [[ "$1" == "-d" ]];then
		echo "clean"
		umount /workdir/rworkdir
		umount /workdir/exports
	fi

}
wmount() {
	[ -d /mnt/iso ] || mkdir -p /mnt/iso
	[ -d /mnt/bug_nfs ] || mkdir -p /mnt/bug_nfs
	[ -d /mnt/gluster ] || mkdir -p /mnt/gluster
	[ -d /mnt/logs ] || mkdir -p /mnt/logs
	echo "mount.glusterfs gluster-virt-qe-01.lab.eng.pek2.redhat.com:/gv0  /mnt/gluster"
	echo "mount 10.73.194.27:/vol/s2kvmauto/iso  /mnt/iso"
	echo "mount 10.73.194.27:/vol/s2kvmauto/iso  /home/kvm_autotest_root/iso"
	echo "mount 10.73.194.27:/vol/S4/virtlablogs /mnt/logs"
	echo "mount -o bind /home/workdir /workdir"
	echo "mount qing:/home/exports /workdir/exports"
	echo "mount 10.73.194.27:/vol/s2images294422  /mnt/bug_nfs/"
	echo "http://fileshare.englab.nay.redhat.com/pub/section2/images_backup"
        echo " ln -s workspace/var/lib/avocado/data/avocado-vt/test-providers.d/downloads/io-github-autotest-qemu tp-qemu; ln -s workspace/avocado-vt avocado-vt; ln -s ./ kar; ln -s workspace/var/lib/avocado/data/avocado-vt/backends/qemu/cfg output-cfg;"
}
wbug(){
	#rsync -avh /workdir/exports/bug/ /workdir/bug/
	if (($#<2));then
		echo -e "Usage: wbug 123 job-xxx\nrsync -avh /workdir/exports/bug/ /workdir/bug/"
		return
	fi
	bugid=$1
	bugdir=/workdir/exports/bug/${bugid}
	logdir="$2 $3 $4 $5 $6"
	
	T=`date  "+%F-%H%M"`
	mkdir -p /workdir/exports/bug/${bugid}
	[[ -f ${bugdir}/${bugid}.tar.gz ]]  && mv ${bugdir}/${bugid}.tar.gz ${bugdir}/${bugid}.tar.gz.$T 
	cmd="tar zcvf ${bugdir}/${bugid}.tar.gz ${logdir}"
    	echo "$cmd"
    	$cmd

}
wlog_clean(){
	logdir=/workdir/exports/logs/
	logid=$1
	if [[ "x$1" != "x" ]];then
		echo "clean"
		[[ -d ${logdir}/${logid}/test-results ]] || return 0
		
		cd ${logdir}/${logid}/test-results
		for sublog in `ls -d */`;do
			if (( ${#sublog} > 5));then
			echo "enter ${sublog}"
			cd ${sublog}
			if  tail -n 3 debug.log |grep -E " PASS ";then
				echo "Pass ${sublog}"
				rm -rf screendumps*
				find ./ -size +2M -exec rm {} \;
			else
				echo "Not Pass ${sublog}"
			fi
			cd -
			fi
		done
		cd ${logdir}
	fi

}
wlog(){
	logdir=/workdir/exports/logs/
	if [[ ! -d ${logdir} ]];then
	    echo "Need mount qing:/home/exports /workdir/exports"
	    return 0
	fi
	if (( $# < 2));then
		echo "$# : Usage: wlog logdir alias"
	fi
	logid=$1
	if [[ -d ${logdir}/${logid} ]] ;then
	    echo "exist ${logdir}/${logid}" 
	else
	    cp -rf ${logid} ${logdir}
	fi

	if [[ "x$2" != "x" ]];then
	    logname=`echo "$2"|tr -d " "`
	    echo "create soft link:${logname}"
	    touch ${logdir}/${logid}/${logname}
	    ln -sf ${logid} ${logname}
	    cd ${logdir}; ln -sf ${logdir}/${logid} ${logname};cd -
	fi
	if [[ "x$3" != "x" ]];then
		wlog_clean $logid
	fi
}

wrdesktop(){
	 rdesktop -g 1600x900 10.73.74.245 -u administrator -p Assentor01
}
export PATH=$PATH:/usr/local/bin
export VTE="./var/lib/avocado/data/avocado-vt/backends/qemu/cfg/tests-example.cfg"

cd
#ulimit -c unlimited
