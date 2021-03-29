def _run_sg_luns():
        script_cmd = """cat << EOF >/tmp/guest-run.sh
trap 'kill \$(jobs -p)' EXIT SIGINT

for i in \`seq 0 32\` ; do
    while true ; do
        sg_luns /dev/sdb > /dev/null 2>&1
    done &
done
echo 'wait'
wait
EOF
chmod 755 /tmp/guest-run.sh
cat /tmp/guest-run.sh
"""
