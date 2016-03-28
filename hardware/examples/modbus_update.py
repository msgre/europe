#!/usr/bin/env python
import serial
import sys
import time
from struct import pack
from struct import unpack
from minimalmodbus import Instrument

RESET_ADDRESS = 0x0002
UNLOCK_ADDRESS = 0xFFFF
UNLOCK_SECRET = [0xCA06, 0x93D8]
BOOTLOADER_SLAVE_ADDRESS = 0x80

PAYLOAD_SIZE = 64   # ATMega168, ATMega88
#PAYLOAD_SIZE = 128  # ATMega328


def read_file_by_chunks(filename, chunksize=32):
    with open(filename, 'rb') as fo:
        while True:
            chunk = fo.read(chunksize)
            if len(chunk) <= 0:
                break
            yield chunk


def get_firmware_as_list(filename, from_address=0x0000, chunksize=32):
    fmw_data = []
    for chunk in read_file_by_chunks(filename, chunksize):
        chunk += chr(0xFF)*(chunksize-len(chunk))
        segment = unpack('>%dH' % (chunksize/2,), chunk)
        fmw_data.append((from_address, segment,))
        from_address = from_address + chunksize/2

    return fmw_data


def packet_print(packet):
    return ':'.join('{:02X}'.format(ord(c)) for c in packet)

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print 'Usage: %s [COM] [SLAVE_ADDRESS] [MSP.bin]' % sys.argv[0]
        exit(1)

    print ':: Modbus updater'

    port = sys.argv[1]
    slave_address = int(sys.argv[2])
    fmw = sys.argv[3]

    inst = Instrument(port, slave_address)
    inst.serial.baudrate = 57600
    inst.serial.timeout = 0.1
    # print inst
    # inst.debug = True

    # Try to reset FW and run bootloader.
    print 'Sending reset to FW... ',
    try:
        inst.write_registers(RESET_ADDRESS, [0xFFFF])
    except IOError:
        print '[no response]'
    except ValueError:
        print '[wrong response]'
    else:
        print '[OK]'

    # Bootloader slave address has MSB set.
    inst.address = BOOTLOADER_SLAVE_ADDRESS | slave_address
    time.sleep(0.5)

    start_time = time.time()

    # Unlock bootloader.
    print 'Sending secret key',
    unlocked = False
    for i in range(10):
        try:
            inst.write_registers(UNLOCK_ADDRESS, UNLOCK_SECRET)
            sys.stdout.write('.')
            sys.stdout.flush()
            unlocked = True
            break
        except IOError:
            sys.stdout.write('!')
            sys.stdout.flush()
            time.sleep(0.1)

    if unlocked is True:
        print ' [OK]'
    else:
        print ' [Fail]'
        print 'BL is not unlocked. Wrong response!'
        exit(1)

    # Get data in chunks
    fmw_data = get_firmware_as_list(fmw, chunksize=PAYLOAD_SIZE)
    print 'Firmware is {} B long.'.format(len(fmw_data) * PAYLOAD_SIZE)
    print 'First address 0x{:04X}.'.format(fmw_data[0][0])
    print 'Last address 0x{:04X}.'.format(fmw_data[-1][0])

    # Write pages from the last one to first one. If there is some error
    # during programming, the firmware won't run because first page contains
    # all interrupts vectors.
    for segment in reversed(fmw_data):
        # Prepare data to send.
        address = segment[0]
        data = segment[1]
        try:
            inst.write_registers(address, list(data))
            sys.stdout.write('.')
            sys.stdout.flush()
        except IOError:
            # Print send and received data -- for debugging.
            print '\nSending failed at address {:04X}!'.format(address)
            break

    print("\nTotal time: %s seconds" % (time.time() - start_time))
