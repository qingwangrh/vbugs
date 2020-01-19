import six
import logging

from avocado.utils import process
from avocado.utils import wait
from virttest import utils_misc
from virttest import utils_test
from virttest import error_context
from virttest import virt_vm
from virttest import qemu_monitor


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
    Customer Bug ID: 1741937  1673546

    Test if VM paused/resume when fc storage offline/online.

    1) pass-through /dev/mapper/mpatha
    2) dd test on pass-through disk
    3) Disconnect the storage during dd test
    4) Check if VM status is 'paused'
    5) Connect the storage, Wait until the storage is accessible again
    6) resume the vm
    7) Check if VM status is 'running'
    8) dd test completed successfully

    :param test: kvm test object.
    :param params: Dictionary with the test parameters.
    :param env: Dictionary with test environment.
    """

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
                      first=wait_time, step=1.5, timeout=60)

    def run_backgroud_process(session, bg_cmd):

        """
        run a background process.

        :param session: A shell session object.
        :param bg_cmd: run it in background.
        :return: background thread
        """
        error_context.context("Start a background process: '%s'" % bg_cmd,
                              logging.info)
        args = (bg_cmd, 360)
        bg = utils_test.BackgroundTest(session.cmd, args)
        bg.start()
        if not utils_misc.wait_for(lambda: bg.is_alive, 60):
            test.fail("Failed to start background process: '%s'" % bg_cmd)
        return bg

    error_context.context("Get FC host name:", logging.info)
    hostname = process.run("hostname", shell=True).stdout.decode().strip()
    if hostname != params["special_host"]:
        test.cancel("The special host is not '%s', cancel the test."
                    % params["special_host"])
    error_context.context("Get FC disk serial name:", logging.info)
    outputs = process.run("multipath -ll", shell=True).stdout.decode().splitlines()
    stg_serial_name = params["stg_serial_name"]
    image_name_stg = params["image_name_stg"]
    mpath_name = image_name_stg.split("/")[-1]
    for output in outputs:
        if stg_serial_name in output and mpath_name in output:
            break
    else:
        test.cancel("The special disk is not '%s', cancel the test."
                    % stg_serial_name)
    wait_time = float(params.get("sub_test_wait_time", 0))
    multi_disks = get_multipath_disks(mpath_name)
    error_context.context("Get all disks for '%s': %s"
                          % (mpath_name, multi_disks), logging.info)
    error_context.context("Verify all paths are running for %s before"
                          "start vm." % mpath_name, logging.info)
    if compare_multipath_status("running", mpath_name):
        logging.info("All paths are running for %s." % mpath_name)
    else:
        test.cancel("Not all paths are running for %s, please "
                    "check environment." % mpath_name)
    vm = env.get_vm(params["main_vm"])
    try:
        vm.create(params=params)
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        vm.resume()
        vm.verify_status("running")
        bg_cmd = params["bg_cmd"]
        bg = run_backgroud_process(session, bg_cmd)
        set_multipath_disks_status(multi_disks, "offline")
        error_context.context("Check if VM status is 'paused'", logging.info)
        if not utils_misc.wait_for(lambda: check_vm_status(vm, "paused"), 60):
            test.fail("Guest is not paused after all disks offline")
        error_context.context("Re-connect fc storage, wait until the "
                              "storage is accessible again", logging.info)
        set_multipath_disks_status(multi_disks, "running")
        error_context.context("Resume the vm.", logging.info)
        vm.resume()
        error_context.context("Check if VM status is 'running'", logging.info)
        if not utils_misc.wait_for(lambda: check_vm_status(vm, "running"), 60):
            test.fail("Guest is not running after all disks online")
        if bg:
            error_context.context("Wait for dd testing completed", logging.info)
            bg.join()
        error_context.context("Verify Host and guest kernel no error "
                              "and call trace", logging.info)
        vm.verify_kernel_crash()
        error_context.context("Verify dmesg no error", logging.info)
        vm.verify_dmesg()
    finally:
        set_multipath_disks_status(multi_disks, "running")
        session.close()
        vm.destroy(gracefully=True)
