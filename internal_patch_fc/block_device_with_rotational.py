import logging
from virttest import qemu_qtree
from virttest import error_context


@error_context.context_aware
def run(test, params, env):
    """
    test block device with rotational_rate option:

    1) Boot up a guest with rotational_rate = 0,
       check the value in qtree and guest.
       in qtree: rotation_rate = 0 (0x0)
       guest: # cat /sys/block/sda/queue/rotational
              1
    2) Boot up a guest with rotational_rate = 1,
       check the value in qtree and guest.
       in qtree: rotation_rate = 1 (0x1)
       guest: # cat /sys/block/sda/queue/rotational
              0
    3) Boot up a guest with rotational_rate = 15000,
       check the value in qtree and guest.
       in qtree: rotation_rate = 15000 (0x3a98)
       guest: # cat /sys/block/sda/queue/rotational
              1

    :param test: QEMU test object
    :param params: Dictionary with the test parameters
    :param env: Dictionary with test environment.
    """

    def get_rotational_rate_in_qtree():
        """ get_rotational_rate_in_qtree """

        error_context.context("Get rotational_rate from monitor.", logging.info)
        qtree = qemu_qtree.QtreeContainer()
        try:
            qtree.parse_info_qtree(vm.monitor.info('qtree'))
        except AttributeError:
            test.cancel("Monitor doesn't support qtree skip this test")
        for node in qtree.get_nodes():
            type = node.qtree['type']
            if isinstance(node, qemu_qtree.QtreeDev) and (type == "scsi-hd"):
                return node.qtree["rotation_rate"].split("(")[0].strip()

    timeout = float(params.get("login_timeout", 360))
    rotation_rate = params['rotation_rate']
    rotational_value = params['rotational_value']
    get_rotational_cmd = params["get_rational_value"]
    get_disk_information = params.get("get_disk_information")
    vm = env.get_vm(params["main_vm"])
    rotational_rate_in_qtree = get_rotational_rate_in_qtree()
    if rotation_rate != rotational_rate_in_qtree:
        test.fail("The rotational_rate is not equal to set value."
                  "Set value in qemu line: %s, value in qtree: %s"
                  % (rotation_rate, rotational_rate_in_qtree))
    session = vm.wait_for_login(timeout=timeout)
    output = session.cmd_output(get_rotational_cmd)
    if rotational_value != output.strip():
        test.fail("The rotational value is not right."
                  "Set value is: %s, value in guest is"
                  ": %s" % (rotational_value, output))
    if get_disk_information:
        output = session.cmd_output(get_disk_information)
        logging.info("Disk information.\n%s" % output)
        rate_value = output.split("Rotation Rate:")[-1].split("rpm")[0].strip()
        if rotation_rate != rate_value:
            test.fail("The rotation rate is not right."
                      "Set value is: %s, value in guest is"
                      ": %s" % (rotation_rate, rate_value))
    session.close()
