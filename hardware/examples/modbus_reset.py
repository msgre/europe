#!/usr/bin/env python

if __name__ == '__main__':
    import sys
    from minimalmodbus import Instrument

    if len(sys.argv) < 3:
        print 'Usage: {} [COM] [SLAVE] <baudrate=57600>'.format(sys.argv[0])
        exit(1)

    port = sys.argv[1]
    slave = int(sys.argv[2])
    try:
        baudrate = int(sys.argv[3])
    except Exception:
        baudrate = 57600

instrument = Instrument(port, slave)
instrument.serial.baudrate = baudrate
instrument.serial.timeout = 1

instrument.write_registers(
    0x0001,    # Address
    [0xFFFF],  # Data, any value will do.
)
