import six
import logging

from avocado.utils import process
from avocado.utils import wait
from virttest import utils_misc
from virttest import error_context


@error_context.context_aware
def run(test, params, env):

    """
    Special hardware test case.
    FC host: ibm-x3650m4-05.lab.eng.pek2.redhat.com
    Disk serial name: scsi-360050763008084e6e0000000000001a4
    # multipath -ll
    mpathb (360050763008084e6e0000000000001a8) dm-4 IBM,2145
    size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
    |-+- policy='service-time 0' prio=50 status=active
    | `- 2:0:1:0 sde 8:64 active ready running
    `-+- policy='service-time 0' prio=10 status=enabled
      `- 2:0:0:0 sdd 8:48 active ready running
    mpatha (360050763008084e6e0000000000001a4) dm-3 IBM,2145
    size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
    |-+- policy='service-time 0' prio=50 status=active
    | `- 1:0:1:0 sdc 8:32 active ready running
    `-+- policy='service-time 0' prio=10 status=enabled
      `- 1:0:0:0 sdb 8:16 active ready running
    Customer Bug ID: 1720047  1753992

    Test multipath persistent reservation.

    1) pass-through /dev/sdb
    2) run persistent reservation related cmds
        #! /bin/sh
        sg_persist --no-inquiry -v --out --register-ignore --param-sark 123aaa "$@"
        sg_persist --no-inquiry --in -k "$@"
        sg_persist --no-inquiry -v --out --reserve --param-rk 123aaa --prout-type 5 "$@"
        sg_persist --no-inquiry --in -r "$@"
        sg_persist --no-inquiry -v --out --release --param-rk 123aaa --prout-type 5 "$@"
        sg_persist --no-inquiry --in -r "$@"
        sg_persist --no-inquiry -v --out --register --param-rk 123aaa --prout-type 5 "$@"
        sg_persist --no-inquiry --in -k "$@"
    3) pass-through /dev/mapper/mpatha
    4) run persistent reservation related cmds

    :param test: kvm test object.
    :param params: Dictionary with the test parameters.
    :param env: Dictionary with test environment.
    """

    def get_multipath_disks(mpath_name="mpatha"):

        """
        Get all disks of multiple paths.
        multipath like below:
        mpatha (360050763008084e6e0000000000001a4) dm-3 IBM,2145
        size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
        |-+- policy='service-time 0' prio=50 status=active
        | `- 1:0:1:0 sdc 8:32  active ready running
        `-+- policy='service-time 0' prio=10 status=enabled
          `- 1:0:0:0 sdb 8:16  active ready running

        :param mpath_name: multi-path name.
        :return: a list. if get disks successfully or raise a error
        """
        disks = []
        disk_str = []
        outputs = process.run("multipath -ll", shell=True).stdout.decode()
        outputs = outputs.split(mpath_name)[-1]
        disk_str.append("active ready running")
        disk_str.append("active faulty offline")
        disk_str.append("failed faulty offline")
        for line in outputs.splitlines():
            if disk_str[0] in line or disk_str[1] in line or disk_str[2] in line:
                disks.append(line.split()[-5])
        if not disks:
            test.fail("Failed to get disks by 'multipath -ll'")
        else:
            return disks

    def get_multipath_disks_status(mpath_name="mpatha"):

        """
        Get status of multiple paths.
        multipath like below:
        mpatha (360050763008084e6e0000000000001a4) dm-3 IBM,2145
        size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
        |-+- policy='service-time 0' prio=50 status=active
        | `- 1:0:1:0 sdc 8:32  active ready running
        `-+- policy='service-time 0' prio=10 status=enabled
          `- 1:0:0:0 sdb 8:16  active ready running

        :param mpath_name: multi-path name.
        :return: a list. if get status successfully or raise a error
        """
        disks = get_multipath_disks(mpath_name)
        disks_status = []
        outputs = process.run("multipath -ll", shell=True).stdout.decode()
        outputs = outputs.split(mpath_name)[-1]
        for line in outputs.splitlines():
            for i in range(len(disks)):
                if disks[i] in line:
                    disks_status.append(line.strip().split()[-1])
                    break
        if not disks_status or len(disks_status) != len(disks):
            test.fail("Failed to get disks status by 'multipath -ll'")
        else:
            return disks_status

    def compare_multipath_status(status, mpath_name="mpatha"):

        """
        Compare status whether equal to the given status.
        This function just focus on all paths are running or all are offline.

        :param status: the state of disks.
        :param mpath_name: multi-path name.
        :return: True, if equal to the given status or False
        """
        status_list = get_multipath_disks_status(mpath_name)
        if len(set(status_list)) == 1 and status_list[0] == status:
            return True
        else:
            return False

    def set_disk_status_to_online_offline(disk, status):

        """
        set disk state to online/offline.
        multipath like below:
        mpatha (360050763008084e6e0000000000001a4) dm-3 IBM,2145
        size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
        |-+- policy='service-time 0' prio=50 status=active
        | `- 1:0:1:0 sdc 8:32  active ready running
        `-+- policy='service-time 0' prio=10 status=enabled
          `- 1:0:0:0 sdb 8:16 failed faulty offline

        :param disk: disk name.
        :param status: the state of disk.
        :return: by default
        """
        error_context.context("Set disk '%s' to status '%s'."
                              % (disk, status), logging.info)
        process.run("echo %s >  /sys/block/%s/device/state"
                    % (status, disk), shell=True)

    def set_multipath_disks_status(disks, status):

        """
        set multiple paths to same status. all disks online or offline.
        multipath like below:
        mpatha (360050763008084e6e0000000000001a4) dm-3 IBM,2145
        size=100G features='1 queue_if_no_path' hwhandler='1 alua' wp=rw
        |-+- policy='service-time 0' prio=50 status=active
        | `- 1:0:1:0 sdc 8:32  active ready running
        `-+- policy='service-time 0' prio=10 status=enabled
          `- 1:0:0:0 sdb 8:16 failed faulty offline

        :param disks: disk list.
        :param status: the state of disk. online/offline
        :return: by default
        """
        for disk in disks:
            set_disk_status_to_online_offline(disk, status)
        wait.wait_for(lambda: compare_multipath_status(status),
                      first=2, step=1.5, timeout=60)

    error_context.context("Get FC host name:", logging.info)
    hostname = process.run("hostname", shell=True).stdout.decode().strip()
    if hostname != params["special_host"]:
        test.cancel("The special host is not '%s', cancel the test."
                    % params["special_host"])
    error_context.context("Get FC disk serial name:", logging.info)
    stg_serial_name = params["stg_serial_name"]
    image_name_stg = params["image_name_stg"].split("/")[-1]
    if "mpath" not in image_name_stg:
        query_cmd = "udevadm info -q property -p /sys/block/%s" % image_name_stg
        outputs = process.run(query_cmd, shell=True).stdout.decode().splitlines()
        for output in outputs:
            # ID_SERIAL=360050763008084e6e0000000000001a4
            if stg_serial_name in output and output.startswith("ID_SERIAL="):
                break
        else:
            test.cancel("The special disk is not '%s', cancel the test."
                        % stg_serial_name)
    else:
        outputs = process.run("multipath -ll", shell=True).stdout.decode().splitlines()
        for output in outputs:
            if stg_serial_name in output and image_name_stg in output:
                break
        else:
            test.cancel("The special disk is not '%s', cancel the test."
                        % stg_serial_name)
        mpath_name = image_name_stg
        multi_disks = get_multipath_disks(mpath_name)
        error_context.context("Get all disks for '%s': %s"
                              % (mpath_name, multi_disks), logging.info)
        error_context.context("Verify all paths are running for %s before "
                              "start vm." % mpath_name, logging.info)
        if compare_multipath_status("running", mpath_name):
            logging.info("All paths are running for %s." % mpath_name)
        else:
            logging.info("Not all paths are running for %s, set "
                         "them to running." % mpath_name)
            set_multipath_disks_status(multi_disks, "running")
    error_context.context("Start service 'qemu-pr-helper'.", logging.info)
    process.run("systemctl start qemu-pr-helper", shell=True)
    process.run("systemctl status qemu-pr-helper", shell=True)
    vm = env.get_vm(params["main_vm"])
    try:
        vm.create(params=params)
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
    logging.info("Get data disk by serial name: '%s'" % stg_serial_name)
    drive_path = utils_misc.get_linux_drive_path(session, stg_serial_name)
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        vm.resume()
        vm.verify_status("running")
        pr_cmds = """
        sg_persist --no-inquiry -v --out --register-ignore --param-sark 123aaa %s
        sg_persist --no-inquiry --in -k %s
        sg_persist --no-inquiry -v --out --reserve --param-rk 123aaa --prout-type 5 %s
        sg_persist --no-inquiry --in -r %s
        sg_persist --no-inquiry -v --out --release --param-rk 123aaa --prout-type 5 %s
        sg_persist --no-inquiry --in -r %s
        sg_persist --no-inquiry -v --out --register --param-rk 123aaa --prout-type 5 %s
        sg_persist --no-inquiry --in -k %s"""
        pr_cmds_check = []
        pr_cmds_check.append("command (Register and ignore existing key) successful")
        pr_cmds_check.append("%s registered reservation key" % params["registered_keys"])
        pr_cmds_check.append("PR out: command (Reserve) successful")
        pr_cmds_check.append("Key=0x123aaa")
        pr_cmds_check.append("PR out: command (Release) successful")
        pr_cmds_check.append("there is NO reservation held")
        pr_cmds_check.append("PR out: command (Register) successful")
        pr_cmds_check.append("there are NO registered reservation keys")
        pr_cmds = pr_cmds.strip().splitlines()
        pr_helper_id = params["pr_manager_helper"]
        error_context.context("Check status of qemu-pr-helper service before "
                              "persistent reservation", logging.info)
        output = vm.monitor.send_args_cmd("query-pr-managers", convert=False)
        # output: [{'connected': True, 'id': 'helper0'}]
        if output[0]["connected"] and output[0]["id"] == pr_helper_id:
            logging.info("output for 'query-pr-managers' via qmp: %s" % output)
        else:
            test.fail("The return value of 'query-pr-managers' via qmp "
                      "monitor is not right: %s" % output)
        for i in range(len(pr_cmds)):
            status, output = session.cmd_status_output(pr_cmds[i].strip() % drive_path)
            if status == 0 and pr_cmds_check[i] in output:
                logging.info("Run command '%s' successfully.\n%s"
                             % (pr_cmds[i].strip() % drive_path, output))
            else:
                test.fail("Failed to run command '%s':\n%s"
                          % (pr_cmds[i].strip() % drive_path, output))
        error_context.context("Check status of qemu-pr-helper service after "
                              "persistent reservation", logging.info)
        output = vm.monitor.send_args_cmd("query-pr-managers", convert=False)
        if output[0]["connected"] and output[0]["id"] == pr_helper_id:
            logging.info("output for 'query-pr-managers' via qmp: %s" % output)
        else:
            test.fail("The return value of 'query-pr-managers' via qmp "
                      "monitor is not right: %s" % output)
    finally:
        session.close()
        vm.destroy(gracefully=True)
