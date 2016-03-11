#!/usr/bin/env python

import sys
import time
from minimalmodbus import Instrument

# Number of Modbus reads.
READS = 1000
# Number of registers to be read.
REGISTERS = 1

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print 'Usage: %s [COM] [SLAVE_ADDRESS]' % sys.argv[0]
        exit(1)

    port = sys.argv[1]
    slave_address = int(sys.argv[2])

    inst = Instrument(port, slave_address)
    inst.serial.baudrate = 57600
    inst.serial.timeout = 1

    start_time = time.time()

    for i in range(READS):
        response = inst.read_registers(0x0000, REGISTERS)
        if response[0] != 0x0000:
            print 'IR inputs: {:02X}'.format(response[0] >> 8)

    end_time = time.time()

    print 'Duration of {} reads from {} register: {:.2f} seconds.'.format(
        READS,
        REGISTERS,
        end_time - start_time,
    )
