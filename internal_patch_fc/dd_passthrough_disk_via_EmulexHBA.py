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

    dd test on passthrough disk.

    1) pass-through /dev/sdb
    2) dd_zero2disk, dd_disk2null
    3) pass-through /dev/mapper/mpatha
    4) dd_zero2disk, dd_disk2null

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

    def check_vm_status(vm, status):
        """
        Check if VM has the given status or not.

        :param vm: VM object.
        :param status: String with desired status.
        :return: True if VM status matches our desired status.
        :return: False if VM status does not match our desired status.
        """
        try:
            vm.verify_status(status)
        except (virt_vm.VMStatusError, qemu_monitor.MonitorLockError):
            return False
        else:
            return True

    def dd_test(session, dd_cmd):
        """
        dd test in guest with different bs.

        :param session: A shell session object.
        :param dd_cmd: dd command
        :return: by default
        """
        for bs in dd_bs:
            cmd = dd_cmd % (drive_path, bs)
            status, output = session.cmd_status_output(cmd)
            if status == 0 and check_vm_status(vm, "running"):
                logging.info("run '%s' successfully:\n%s" % (cmd, output))
            else:
                test.fail("Failed to run '%s':\n%s" % (cmd, output))

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
    vm = env.get_vm(params["main_vm"])
    try:
        vm.create(params=params)
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
    logging.info("Get data disk by serial name: '%s'" % stg_serial_name)
    drive_path = utils_misc.get_linux_drive_path(session, stg_serial_name)
    dd_zero2disk = params["dd_zero2disk"]
    dd_disk2null = params["dd_disk2null"]
    dd_bs = params["dd_bs"].split()
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        vm.resume()
        vm.verify_status("running")
        error_context.context("Execute dd (zero2disk) in guest", logging.info)
        dd_test(session, dd_zero2disk)
        error_context.context("Execute dd (disk2null) in guest", logging.info)
        dd_test(session, dd_disk2null)
        error_context.context("Verify dmesg no error", logging.info)
        vm.verify_dmesg()
    finally:
        session.close()
        vm.destroy(gracefully=True)
