import re
import six
import random
import string
import logging

from avocado.utils import process
from avocado.utils import wait
# from virttest import utils_misc
from virttest import utils_disk
from virttest import error_context
from provider.storage_benchmark import generate_instance


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

    format passthrough disk and do iozone test on it.

    1) pass-through /dev/sdb
    2) format it and do iozone test
    3) pass-through /dev/sg1
    4) format it and do iozone test
    5) pass-through /dev/mapper/mpatha
    6) format it and do iozone test

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

    def get_disk_by_sg_map(image_name_stg):
        """
        get disk name by sg_map.

        :param image_name_stg: linux sg. e.g. /dev/sg1
        :return: disk name. e.g. sdb
        """
        outputs = process.run("sg_map", shell=True).stdout.decode().splitlines()
        for output in outputs:
            if image_name_stg in output:
                return output.strip().split()[-1].split("/")[-1]

    def _get_windows_disks_index(session, image_size):
        """
        Get all disks index which show in 'diskpart list disk'.
        except for system disk.
        in diskpart: if disk size < 8GB: it displays as MB
                     else: it displays as GB

        :param session: session object to guest.
        :param image_size: image size. e.g. 40M
        :return: a list with all disks index except for system disk.
        """
        disk = "disk_" + ''.join(random.sample(string.ascii_letters + string.digits, 4))
        disk_indexs = []
        list_disk_cmd = "echo list disk > " + disk
        list_disk_cmd += " && echo exit >> " + disk
        list_disk_cmd += " && diskpart /s " + disk
        list_disk_cmd += " && del /f " + disk
        disks = session.cmd_output(list_disk_cmd)
        size_type = image_size[-1] + "B"
        if size_type == "MB":
            disk_size = image_size[:-1] + " MB"
        elif size_type == "GB" and int(image_size[:-1]) < 8:
            disk_size = str(int(image_size[:-1]) * 1024) + " MB"
        else:
            disk_size = image_size[:-1] + " GB"
        regex_str = 'Disk (\d+).*?%s' % disk_size
        for disk in disks.splitlines():
            if disk.startswith("  Disk"):
                o = re.findall(regex_str, disk, re.I | re.M)
                if o:
                    disk_indexs.append(o[0])
        return disk_indexs

    def delete_partition_on_host(did):
        """
        Delete partitions on the given disk.

        :param did: disk ID. disk kname. e.g. 'sdb', 'nvme0n1'
        :return: by default.
        """
        # process.run("partprobe /dev/%s" % did, shell=True)
        list_disk_cmd = "lsblk -o KNAME,MOUNTPOINT"
        output = process.run(list_disk_cmd, shell=True).stdout.decode()
        regex_str = did + "\w*(\d+)"
        rm_cmd = 'parted -s "/dev/%s" rm %s'
        for line in output.splitlines():
            partition = re.findall(regex_str, line, re.I | re.M)
            if partition:
                if "/" in line.split()[-1]:
                    process.run("umount %s" % line.split()[-1], shell=True)
        list_partition_number = "parted -s /dev/%s print|awk '/^ / {print $1}'"
        partition_numbers = process.run(list_partition_number % did,
                                        shell=True).stdout.decode()
        ignore_err_msg = "unrecognised disk label"
        if ignore_err_msg in partition_numbers:
            logging.info("no partition to delete on %s" % did)
        else:
            partition_numbers = partition_numbers.splitlines()
            for number in partition_numbers:
                logging.info("remove partition %s on %s" % (number, did))
                process.run(rm_cmd % (did, number), shell=True)
            process.run("partprobe /dev/%s" % did, shell=True)

    def delete_multipath_partition_on_host(mpath_name="mpatha"):
        """
        Delete partitions on the given multipath.

        :param mpath_name: multi-path name.
        :return: by default.
        """
        # process.run("partprobe /dev/mapper/%s" % mpath_name, shell=True)
        output = process.run("lsblk", shell=True).stdout.decode()
        mpath_dict = {}
        pattern = r'%s(\d+)' % mpath_name
        rm_cmd = 'parted -s "/dev/mapper/%s" rm %s'
        for line in output.splitlines():
            for part_num in re.findall(pattern, line, re.I | re.M):
                if part_num not in mpath_dict.keys():
                    mpath_dict[part_num] = line.split()[-1]
        for key, value in mpath_dict.items():
            if "/" in value:
                process.run("umount %s" % value, shell=True)
            logging.info("remove partition %s on %s" % (key, mpath_name))
            process.run(rm_cmd % (mpath_name, key), shell=True)
        output = process.run("dmsetup ls", shell=True).stdout.decode()
        for line in output.splitlines():
            for key in mpath_dict.keys():
                if (mpath_name + key) in line:
                    process.run("dmsetup remove %s%s" % (mpath_name, key),
                                shell=True)
        process.run("partprobe /dev/mapper/%s" % mpath_name, shell=True)

    def clean_partition_on_host(mpath_name="mpatha"):
        """
        Delete partitions on multi-path disks.

        :param mpath_name: multi-path name.
        :return: by default
        """
        delete_multipath_partition_on_host(mpath_name)
        disks = get_multipath_disks(mpath_name)
        for disk in disks:
            delete_partition_on_host(disk)

    error_context.context("Get FC host name:", logging.info)
    hostname = process.run("hostname", shell=True).stdout.decode().strip()
    if hostname != params["special_host"]:
        test.cancel("The special host is not '%s', cancel the test."
                    % params["special_host"])
    error_context.context("Get FC disk serial name:", logging.info)
    stg_serial_name = params["stg_serial_name"]
    image_name_stg = params["image_name_stg"].split("/")[-1]
    if "mpath" not in image_name_stg:
        if "sg" in image_name_stg:
            image_name_stg = get_disk_by_sg_map(image_name_stg)
            if not image_name_stg:
                test.cancel("Failed to get disk by sg_map,"
                            " output is '%s'" % image_name_stg)
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
    error_context.context("Delete partitions on host before testing.",
                          logging.info)
    clean_partition_on_host(params["mpath_name"])
    vm = env.get_vm(params["main_vm"])
    try:
        vm.create(params=params)
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
    file_system = [_.strip() for _ in params["file_system"].split()]
    labeltype = params.get("labeltype", "gpt")
    iozone_target_num = int(params.get('iozone_target_num', '5'))
    iozone_options = params.get('iozone_options')
    iozone_timeout = float(params.get('iozone_timeout', '7200'))
    image_num_stg = int(params["image_num_stg"])
    image_size_stg = params["image_size_stg"]
    ostype = params["os_type"]
    try:
        if ostype == "windows":
            error_context.context("Get windows disk index that to "
                                  "be formatted", logging.info)
            # disks = utils_disk.get_windows_disks_index(session, image_size_stg)
            disks = _get_windows_disks_index(session, image_size_stg)
            if len(disks) != image_num_stg:
                test.fail("Failed to list all disks by image size. The expected "
                          "is %s, actual is %s" % (image_num_stg, len(disks)))
            error_context.context("Clear readonly for all disks and online "
                                  "them in windows guest.", logging.info)
            if not utils_disk.update_windows_disk_attributes(session, disks):
                test.fail("Failed to update windows disk attributes.")
        else:
            error_context.context("Get linux disk that to be "
                                  "formatted", logging.info)
            disks = sorted(utils_disk.get_linux_disks(session).keys())
            if len(disks) != image_num_stg:
                test.fail("Failed to list all disks by image size. The expected "
                          "is %s, actual is %s" % (image_num_stg, len(disks)))
            # logging.info("Get data disk by serial name: '%s'" % stg_serial_name)
            # drive_path = utils_misc.get_linux_drive_path(session, stg_serial_name)
            # if not drive_path:
            #     test.fail("Failed to get data disk by serial name: %s"
            #               % stg_serial_name)
    except Exception:
        _do_post_cmd(session)
        raise
    if iozone_options:
        iozone = generate_instance(params, vm, 'iozone')
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        vm.resume()
        vm.verify_status("running")
        for n, disk in enumerate(disks):
            error_context.context("Format disk in guest: '%s'" % disk,
                                  logging.info)
            # Random select one file system from file_system
            index = random.randint(0, (len(file_system) - 1))
            fstype = file_system[index].strip()
            partitions = utils_disk.configure_empty_disk(
                session, disk, image_size_stg, ostype,
                fstype=fstype, labeltype=labeltype)
            if not partitions:
                test.fail("Fail to format disks.")
            for partition in partitions:
                if iozone_options and n < iozone_target_num:
                    iozone.run(iozone_options.format(partition), iozone_timeout)
        error_context.context("Reboot guest after format disk "
                              "and iozone test.", logging.info)
        session = vm.reboot(session=session, timeout=int(params.get("timeout", 240)))
        error_context.context("Shutting down guest after reboot it.", logging.info)
        vm.graceful_shutdown(timeout=int(params.get("timeout", 240)))
        if vm.is_alive():
            test.fail("Fail to shut down guest.")
        error_context.context("Start the guest again.", logging.info)
        vm = env.get_vm(params["main_vm"])
        vm.create(params=params)
        session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
        error_context.context("Delete partitions in guest.", logging.info)
        for disk in disks:
            utils_disk.clean_partition(session, disk, ostype)
        error_context.context("Inform the OS of partition table changes "
                              "after testing.", logging.info)
        if "sg1" in params["image_name_stg"]:
            image_name_stg = get_disk_by_sg_map(params["image_name_stg"])
            process.run("partprobe /dev/%s" % image_name_stg, shell=True)
        else:
            process.run("partprobe %s" % params["image_name_stg"], shell=True)
    finally:
        if iozone_options:
            iozone.clean()
        _do_post_cmd(session)
