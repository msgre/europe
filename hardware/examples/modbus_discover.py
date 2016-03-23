#!/usr/bin/env python

import sys
import time

from minimalmodbus import Instrument

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print 'Usage: %s [COM]' % sys.argv[0]
        exit(1)

    port = sys.argv[1]

    inst = Instrument(port, 1)
    inst.serial.baudrate = 57600
    inst.serial.timeout = 0.1

    for i in range(1, 16):
        try:
            inst.address = i
            response = inst.read_registers(0x0001, 1)
        except IOError:
            pass
        else:
            print hex(response[0])
            fw_version = response[0] & 0x0FFF
            hw_version = response[0] >> 12
            print 'Slave {}: FW {:03X}, HW {:01X}'.format(i, fw_version, hw_version)
        time.sleep(0.01)

    print 'Done.'
