#!/usr/bin/env python3

import socket
import os
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <command>")
    sys.exit(1)

filename="/tmp/test.sock"
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
if os.path.exists(filename):
    os.remove(filename)
sock.bind(filename)
sock.set_inheritable(True)
sock.listen(1)
print(f"Opened socket on file descriptor {sock.fileno()}")

exitcode = os.spawnlp(os.P_WAIT, sys.argv[1], *sys.argv[1:])
sys.exit(exitcode)