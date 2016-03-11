#!/usr/bin/env python

import sys
from minimalmodbus import Instrument

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print 'Usage: %s [COM] [SLAVE_ADDRESS]' % sys.argv[0]
        exit(1)

    port = sys.argv[1]
    slave_address = int(sys.argv[2])

    inst = Instrument(port, slave_address)
    inst.serial.baudrate = 57600
    inst.serial.timeout = 1
    # inst.debug = True
    # print inst

    # Read both registers from slave.
    response = inst.read_registers(0x0000, 1)
    print 'IR inputs: {:02X}'.format(response[0] >> 8)
