import six
import random
import logging

from avocado.utils import process
from virttest import utils_misc
from virttest import utils_disk
from virttest import error_context


@error_context.context_aware
def run(test, params, env):

    """
    Special hardware test case.
    host: dell-per740xd-01.lab.eng.pek2.redhat.com
    Disk serial name: scsi-36d0946607a154f0023a0939504fa3b93
    Customer Bug ID: 1640927  1566195

    dd & format passthrough disk.

    1) Fetch SCSI VPD page, it must be failed.
       e.g.
       # sg_vpd -p bl /dev/sdb
       fetching VPD page failed: Numerical argument out of domain
       sg_vpd failed: Numerical argument out of domain
    2) sg_map
       e.g.
       # sg_map
       /dev/sg0  /dev/sda
       /dev/sg1  /dev/sdb
       /dev/sg2  /dev/sdc
    3) pass-through /dev/sg1
    4) dd test on it
    5) format it
    6) dd test on it
    7) check special string in dmesg

    :param test: kvm test object.
    :param params: Dictionary with the test parameters.
    :param env: Dictionary with test environment.
    """

    def _do_post_cmd(session):
        """
        do post command after test.

        :param session: A shell session object.
        :return: by default
        """
        cmd = params.get("post_cmd")
        if cmd:
            session.cmd_status_output(cmd)
        session.close()

    def get_disk_sg_by_sg_map(image_name_stg):
        """
        get linux sg name by sg_map.

        :param image_name_stg: image name. e.g. /dev/sdb
        :return: disk sg. e.g. /dev/sg1
        """
        outputs = process.run("sg_map", shell=True).stdout.decode().splitlines()
        for output in outputs:
            if image_name_stg in output:
                return output.strip().split()[0]

    def get_disk_by_serial_name(serial_name):
        """
        get disk name by serial name.

        :param serial_name: e.g. 36d0946607a154f0023a0939504fa3b93
        :return: disk name. e.g. sdb
        """
        cmd = "ls -l /dev/disk/by-id/scsi-%s" % serial_name
        return process.run(cmd, shell=True).stdout.decode().strip().split("/")[-1]

    def dd_test(session, dd_cmd):
        """
        dd test in guest.

        :param session: A shell session object.
        :param dd_cmd: dd command
        :return: by default
        """
        error_context.context("Execute dd test in guest", logging.info)
        status, output = session.cmd_status_output(dd_cmd)
        if status == 0:
            logging.info("run '%s' successfully:\n%s" % (dd_cmd, output))
        else:
            test.fail("Failed to run '%s':\n%s" % (dd_cmd, output))

    error_context.context("Get host name:", logging.info)
    hostname = process.run("hostname", shell=True).stdout.decode().strip()
    if hostname != params["special_host"]:
        test.cancel("The special host is not '%s', cancel the test."
                    % params["special_host"])
    error_context.context("Get disk serial name:", logging.info)
    stg_serial_name = params["stg_serial_name"]
    image_name_stg = get_disk_by_serial_name(stg_serial_name)
    if "sd" not in image_name_stg:
        test.cancel("The special disk is not '%s', cancel the test."
                    % stg_serial_name)
    vpd_page_check = params["vpd_page_check"].split(";")
    error_context.context("Fetch SCSI VPD page before test.",
                          logging.info)
    outputs = process.run("sg_vpd -p bl /dev/%s" % image_name_stg,
                          ignore_status=True,
                          shell=True).stdout.decode().splitlines()
    for output in outputs:
        if not(vpd_page_check[0] in output or vpd_page_check[-1] in output):
            test.cancel("Fetching SCSI VPD page must be failed "
                        "on the special disk, cancel the test.")
    params["image_name_stg"] = get_disk_sg_by_sg_map(image_name_stg)
    vm = env.get_vm(params["main_vm"])
    try:
        vm.create(params=params)
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
    file_system = [_.strip() for _ in params["file_system"].split()]
    labeltype = params.get("labeltype", "gpt")
    image_size_stg = params["image_size_stg"]
    dd_cmd = params["dd_cmd"]
    error_check = params["error_check"].split(";")
    ostype = params["os_type"]
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        vm.resume()
        vm.verify_status("running")
        error_context.context("Get data disk by serial name: '%s'"
                              % stg_serial_name, logging.info)
        drive_path = utils_misc.get_linux_drive_path(session, stg_serial_name)
        if not drive_path:
            test.fail("Failed to get data disk by serial name: %s"
                      % stg_serial_name)
        dd_test(session, dd_cmd % drive_path)
        error_context.context("Format disk in guest: '%s'"
                              % drive_path.split("/")[-1], logging.info)
        # Random select one file system from file_system
        index = random.randint(0, (len(file_system) - 1))
        fstype = file_system[index].strip()
        partitions = utils_disk.configure_empty_disk(
            session, drive_path.split("/")[-1], image_size_stg,
            ostype, fstype=fstype, labeltype=labeltype)
        if not partitions:
            test.fail("Fail to format disks.")
        for partition in partitions:
            dd_test(session, dd_cmd % (partition + "/testfile"))
        error_context.context("Check error string in dmesg.", logging.info)
        for s in error_check:
            output = session.cmd_output(
                'dmesg | grep "%s"' % (s % drive_path.split("/")[-1]))
            if output:
                test.fail("Found error in dmesg:\n%s" % output)
        error_context.context("Verify dmesg no error", logging.info)
        vm.verify_dmesg()
    finally:
        _do_post_cmd(session)
