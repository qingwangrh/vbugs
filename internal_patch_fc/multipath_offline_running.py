# coding=utf-8

import re
import six
import time
import string
import random
import logging

from avocado.utils import process
from avocado.utils import wait
from virttest import utils_misc
from virttest import utils_disk
from virttest import utils_test
from virttest import error_context
from virttest import virt_vm
from virttest import qemu_monitor
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
    Customer Bug ID: 1741937  1673546

    Test if VM paused/resume when fc storage offline/online.

    1) pass-through /dev/mapper/mpatha
    2) install guest on pass-through disk
    3) Disconnect the storage during installation
    4) Check if VM status is 'paused'
    5) Connect the storage, Wait until the storage is accessible again
    6) resume the vm
    7) Check if VM status is 'running'
    8) installation completed successfully
    9) re-pass-through /dev/mapper/mpatha
    10) fio test on pass-through disk
    11) Disconnect any path of multipath during fio testing
    12) Check if VM status is 'paused'
    13) Connect the storage, Wait until the storage is accessible again
    14) resume the vm
    15) fio testing completed successfully

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
            current_status = vm.monitor.get_status()
            vm.verify_status(status)
        except (virt_vm.VMStatusError, qemu_monitor.MonitorLockError):
            logging.info("Failed to check vm status, it is '%s' "
                         "instead of '%s'" % (current_status, status))
            return False
        except Exception as e:
            logging.info("Failed to check vm status: %s" % six.text_type(e))
            logging.info("vm status is '%s' instead of"
                         " '%s'" % (current_status, status))
            return False
        else:
            logging.info("Check vm status successfully. It is '%s'" % status)
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
        disk_str.append("failed ready running")
        for line in outputs.splitlines():
            if disk_str[0] in line or disk_str[1] in line or disk_str[2] \
                    in line or disk_str[3] in line:
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
        :return: a dict. e.g. {"sdb": "running", "sdc": "running"}
        """
        disks = get_multipath_disks(mpath_name)
        disks_status = {}
        outputs = process.run("multipath -ll", shell=True).stdout.decode()
        outputs = outputs.split(mpath_name)[-1]
        for line in outputs.splitlines():
            for i in range(len(disks)):
                if disks[i] in line:
                    disks_status[disks[i]] = line.strip().split()[-1]
                    break
        if not disks_status or len(disks_status) != len(disks):
            logging.info("Failed to get disks status by 'multipath -ll'")
            return {}
        else:
            return disks_status

    def compare_onepath_status(status, disk):

        """
        Compare status whether equal to the given status.
        This function just focus on all paths are running or all are offline.

        :param status: the state of disks.
        :param disk: disk kname.
        :return: True, if equal to the given status or False
        """
        status_dict = get_multipath_disks_status(mpath_name)
        if disk in status_dict.keys() and status == status_dict[disk]:
            return True
        else:
            return False

    def compare_multipath_status(status, mpath_name="mpatha"):

        """
        Compare status whether equal to the given status.
        This function just focus on all paths are running or all are offline.

        :param status: the state of disks.
        :param mpath_name: multi-path name.
        :return: True, if equal to the given status or False
        """
        status_dict = get_multipath_disks_status(mpath_name)
        if len(set(status_dict.values())) == 1 and status in status_dict.values():
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
        if len(disks) == 1:
            wait.wait_for(lambda: compare_onepath_status(status, disks[0]),
                          first=wait_time, step=1.5, timeout=60)
        else:
            wait.wait_for(lambda: compare_multipath_status(status),
                          first=wait_time, step=1.5, timeout=60)

    def get_lvm_dm_name(blkdevs_used):

        """
        Get dm name for lvm. such as rhel_ibm--x3650m4--05-root in below
        NAME                           MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
        sda                              8:0    0 278.9G  0 disk
        ├─sda1                           8:1    0     1G  0 part  /boot
        └─sda2                           8:2    0 277.9G  0 part
            ├─rhel_ibm--x3650m4--05-root 253:0    0    50G  0 lvm   /
            ├─rhel_ibm--x3650m4--05-swap 253:1    0  15.7G  0 lvm   [SWAP]
            └─rhel_ibm--x3650m4--05-home 253:2    0 212.2G  0 lvm   /home
        # ls /dev/mapper/* -l
        crw-------. 1 root root 10, 236 Oct 25 02:07 /dev/mapper/control
        lrwxrwxrwx. 1 root root       7 Oct 25 09:26 /dev/mapper/mpatha -> ../dm-3
        lrwxrwxrwx. 1 root root       7 Oct 25 09:26 /dev/mapper/mpatha1 -> ../dm-5
        lrwxrwxrwx. 1 root root       7 Oct 25 09:26 /dev/mapper/mpatha2 -> ../dm-6
        lrwxrwxrwx. 1 root root       7 Oct 25 06:49 /dev/mapper/mpathb -> ../dm-4
        lrwxrwxrwx. 1 root root       7 Oct 25 09:17 /dev/mapper/rhel_bootp--73--199--5-home -> ../dm-8
        lrwxrwxrwx. 1 root root       7 Oct 25 09:17 /dev/mapper/rhel_bootp--73--199--5-root -> ../dm-9
        lrwxrwxrwx. 1 root root       7 Oct 25 09:17 /dev/mapper/rhel_bootp--73--199--5-swap -> ../dm-7
        lrwxrwxrwx. 1 root root       7 Oct 25 02:07 /dev/mapper/rhel_ibm--x3650m4--05-home -> ../dm-2
        lrwxrwxrwx. 1 root root       7 Oct 25 02:07 /dev/mapper/rhel_ibm--x3650m4--05-root -> ../dm-0
        lrwxrwxrwx. 1 root root       7 Oct 25 02:07 /dev/mapper/rhel_ibm--x3650m4--05-swap -> ../dm-1
        -rw-r--r--. 1 root root       0 Oct 25 07:52 /dev/mapper/vg_raid10-lv_home
        # dmsetup info -c -o name,blkdevs_used
        Name                        BlkDevNamesUsed
        rhel_bootp--73--199--5-home dm-6
        mpathb                      sdd,sde
        mpatha                      sdb,sdc
        mpatha2                     dm-3
        rhel_bootp--73--199--5-swap dm-6
        rhel_bootp--73--199--5-root dm-6
        mpatha1                     dm-3
        rhel_ibm--x3650m4--05-home  sda2
        rhel_ibm--x3650m4--05-swap  sda2
        rhel_ibm--x3650m4--05-root  sda2

        :param blkdevs_used: block name, e.g. sda2
        :return: a list contains all dm name for one blkdev
        """
        dm_list = []
        logging.info("Get dm name for '%s'" % blkdevs_used)
        output = process.run("ls /dev/mapper/* -l",
                             shell=True).stdout.decode()
        for line in output.splitlines():
            if blkdevs_used in line:
                dm_name = line.split("/")[-1]
                break
        output = process.run("dmsetup info -c -o name,blkdevs_used",
                             shell=True).stdout.decode()
        for line in output.splitlines():
            if dm_name == line.split()[-1]:
                dm_list.append(line.split()[0])
        return dm_list

    def delete_lvm_on_multipath(mpath_name="mpatha"):
        """
        Delete lvm on the given multipath.

        :param mpath_name: multi-path name.
        :return: by default.
        """
        output = process.run("pvscan", shell=True).stdout.decode()
        pv_list = []
        vg_list = []
        lv_list = []
        for line in output.splitlines():
            if mpath_name in line:
                if line.split()[1] not in pv_list:
                    pv_list.append(line.split()[1])
                if line.split()[3] not in vg_list:
                    vg_list.append(line.split()[3])
        output = process.run("lvscan", shell=True).stdout.decode()
        for line in output.splitlines():
            for vg in vg_list:
                lv = "/dev/%s/" % vg
                if lv in line and line.split("'")[1] not in lv_list:
                    lv_list.append(line.split("'")[1])
        logging.info("pv list: %s" % pv_list)
        logging.info("vg list: %s" % vg_list)
        logging.info("lv list: %s" % lv_list)
        for lv in lv_list:
            logging.info("Remove lvm '%s'." % lv)
            process.run("lvremove -y %s" % lv, ignore_status=True, shell=True)
        for vg in vg_list:
            logging.info("Remove vg '%s'." % vg)
            process.run("vgremove -y %s" % vg, ignore_status=True, shell=True)
        for pv in pv_list:
            pv_name = pv.split("/")[-1]
            for dm in get_lvm_dm_name(pv_name):
                process.run("dmsetup remove %s" % dm,
                            ignore_status=True, shell=True)
            logging.info("Remove pv '%s'." % pv)
            process.run("pvremove -y %s" % pv, ignore_status=True, shell=True)

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
                                        ignore_status=True,
                                        shell=True).stdout.decode()
        ignore_err_msg = "unrecognised disk label"
        if ignore_err_msg in partition_numbers:
            logging.info("no partition to delete on %s" % did)
        else:
            partition_numbers = partition_numbers.splitlines()
            for number in partition_numbers:
                logging.info("remove partition %s on %s" % (number, did))
                process.run(rm_cmd % (did, number),
                            ignore_status=True, shell=True)
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
            process.run(rm_cmd % (mpath_name, key),
                        ignore_status=True, shell=True)
        output = process.run("dmsetup ls", shell=True).stdout.decode()
        for line in output.splitlines():
            for key in mpath_dict.keys():
                if (mpath_name + key) in line:
                    process.run("dmsetup remove %s%s" % (mpath_name, key),
                                ignore_status=True,
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

    def _run_fio_background(filename):
        """run fio testing by thread"""

        logging.info("Start fio in background.")
        args = (params['fio_options'] % filename, 3600)
        fio_thread = utils_misc.InterruptedThread(fio_multipath.run, args)
        fio_thread.start()
        if not utils_misc.wait_for(lambda: fio_thread.is_alive, 60):
            test.fail("Failed to start fio thread.")
        return fio_thread

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

    def resume_vm_plus(vm, timeout=120):
        """resume vm when it is paused.

        :param vm: VM object.
        :param timeout: re-try times, if it is still paused after resume
        :return: True or None.
                 If resume successfully return True or return None
        """
        logging.info("Try to resume vm within %s seconds." % timeout)
        try:
            vm_status = vm.resume(timeout=timeout)
        except Exception as e:
            logging.error("Failed to resume vm: %s" % six.text_type(e))
        return vm_status

    def resume_vm(vm, n_repeat=3):
        """resume vm when it is paused.

        :param vm: VM object.
        :param n_repeat: re-try times, if it is still paused after resume
        :return: True or False.
                 If resume successfully return True or return False
        """
        for i in range(1, n_repeat + 1):
            logging.info("Try to resume vm %s time(s)" % i)
            try:
                vm.resume()
                time.sleep(wait_time * 15)
            except Exception as e:
                logging.error("Failed to resume vm: %s" % six.text_type(e))
            finally:
                if check_vm_status(vm, "running"):
                    return True
                if vm.is_paused() and i == 3:
                    return False

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
    repeat_times = int(params.get("repeat_times", 3))
    multi_disks = get_multipath_disks(mpath_name)
    error_context.context("Get all disks for '%s': %s"
                          % (mpath_name, multi_disks), logging.info)
    error_context.context("Verify all paths are running for %s before"
                          "start vm." % mpath_name, logging.info)
    if compare_multipath_status("running", mpath_name):
        logging.info("All paths are running for %s." % mpath_name)
    else:
        logging.info("Not all paths are running for %s, set "
                     "them to running." % mpath_name)
        set_multipath_disks_status(multi_disks, "running")
    error_context.context("Delete lvm on multipath disks on host "
                          "before testing.", logging.info)
    delete_lvm_on_multipath(mpath_name)
    error_context.context("Delete partitions on host before testing.",
                          logging.info)
    clean_partition_on_host(mpath_name)
    vm = env.get_vm(params["main_vm"])
    try:
        if params.get("need_install") == "yes":
            error_context.context("Install guest on passthrough disk:",
                                  logging.info)
            args = (test, params, env)
            bg = utils_misc.InterruptedThread(utils_test.run_virt_sub_test, args,
                                              {"sub_type": "unattended_install"})
            bg.start()
            utils_misc.wait_for(bg.is_alive, timeout=10)
            time.sleep(random.uniform(60, 180))
        else:
            vm.create(params=params)
            fio_multipath = generate_instance(params, vm, 'fio')
            session = vm.wait_for_login(timeout=int(params.get("timeout", 240)))
            image_size_stg = params["image_size_stg"]
            image_num_stg = int(params["image_num_stg"])
            os_type = params["os_type"]
    except Exception as e:
        test.error("failed to create VM: %s" % six.text_type(e))
    try:
        error_context.context("Make sure guest is running before test",
                              logging.info)
        if vm.is_paused():
            vm.resume()
        vm.verify_status("running")
        if "fio_multipath" in locals().keys():
            if os_type == "windows":
                error_context.context("Get windows disk index that to "
                                      "be formatted", logging.info)
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
            file_system = [_.strip() for _ in params["file_system"].split()]
            labeltype = params.get("labeltype", "gpt")
            for n, disk in enumerate(disks):
                error_context.context("Format disk in guest: '%s'" % disk,
                                      logging.info)
                # Random select one file system from file_system
                index = random.randint(0, (len(file_system) - 1))
                fstype = file_system[index].strip()
                partitions = utils_disk.configure_empty_disk(
                    session, disk, image_size_stg, os_type,
                    fstype=fstype, labeltype=labeltype)
                if not partitions:
                    test.fail("Fail to format disks.")
            fio_file_name = params["fio_file_name"] % partitions[0]
            fio_thread = _run_fio_background(fio_file_name)

        # disk = random.sample(multi_disks, 1)
        for disk in multi_disks:
            error_context.context("Disable disk %s during guest running"
                                  % disk, logging.info)
            set_multipath_disks_status([disk], "offline")
            time.sleep(wait_time * 15)
            if vm.is_paused():
                logging.info("vm is paused, will resume it.")
                if not resume_vm(vm, repeat_times):
                    test.fail("Failed to resume guest after disable one disk")
                logging.info("Has resumed vm already. Then verify it running.")
                if not utils_misc.wait_for(
                        lambda: check_vm_status(vm, "running"), 60):
                    test.fail("Guest is not running after disable one disk")
            error_context.context("Enable disk %s during guest running"
                                  % disk, logging.info)
            set_multipath_disks_status([disk], "running")
            time.sleep(wait_time * 15)
        error_context.context("Disable multipath '%s' during guest "
                              "running." % mpath_name, logging.info)
        set_multipath_disks_status(multi_disks, "offline")
        time.sleep(wait_time * 15)
        error_context.context("Check if VM status is 'paused'", logging.info)
        if not utils_misc.wait_for(lambda: check_vm_status(vm, "paused"), 120):
            test.fail("Guest is not paused after all disks offline")
        error_context.context("Re-connect fc storage, wait until the "
                              "storage is accessible again", logging.info)
        set_multipath_disks_status(multi_disks, "running")
        time.sleep(wait_time * 15)
        error_context.context("vm is paused, resume it.", logging.info)
        if not resume_vm(vm, repeat_times):
            test.fail("Failed to resume guest after enable multipath.")
        logging.info("Has resumed vm already. Then verify it running.")
        time.sleep(wait_time * 15)
        error_context.context("Check if VM status is 'running'", logging.info)
        if not utils_misc.wait_for(lambda: check_vm_status(vm, "running"), 120):
            test.fail("Guest is not running after all disks online")
        if "bg" in locals().keys() and bg.is_alive and not vm.is_paused():
            bg.join()
        if "fio_thread" in locals().keys() and fio_thread.is_alive \
                and not vm.is_paused():
            fio_thread.join()
        error_context.context("Verify Host and guest kernel no error "
                              "and call trace", logging.info)
        vm.verify_kernel_crash()
    finally:
        logging.info("Finally, clean environment.")
        set_multipath_disks_status(multi_disks, "running")
        if "session" in locals().keys() and session:
            session.close()
        if "fio_multipath" in locals().keys() and fio_multipath \
                and not vm.is_paused():
            fio_multipath.clean()
        if vm.is_alive():
            vm.destroy(gracefully=True)
