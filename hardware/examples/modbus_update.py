#!/usr/bin/env python
import serial
import sys
import time
from struct import pack
from struct import unpack

UNLOCK_ADDRESS = 0xFFFF
UNLOCK_SECRET = [0x39AD, 0xB3F4]
PAYLOAD_SIZE = 128


class MBUpdater(object):
    def __init__(self, serial_port, slave, baudrate=57600):
        self.s = serial.Serial(
            port = serial_port,
            baudrate = baudrate,
            timeout = 1,
        )
        self.s.setDTR(True)  # RS485 input

        self.slave = slave

    def close(self):
        self.s.close()

    def read_data(self, addr, size=128):
        # big-endian, b = unsigned char, H = unsigned short
        cmd = pack('>BBHH', self.slave, 0x03, addr, size)
        crc = self.crc16(cmd)
        return cmd + pack('<H', crc)

    def send_data(self, addr, data):
        # big-endian, b = unsigned char, H = unsigned short
        packet = pack(
            '>BBHHB%dH' % len(data),
            self.slave,    # Slave address
            0x10,          # Command type
            addr,          # Register address
            len(data),     # Number of registers
            2*len(data),   # Number of bytes
            *data          # Data
        )
        crc = self.__crc16(packet)
        self.__write_to_serial(packet + pack('<H', crc))

    def read_response(self, data_size=0):
        resp = self.s.read(8+data_size)
        return self.__check_response(resp), resp

    def __write_to_serial(self, data):
        # self.s.setDTR(False)  # RS485 output
        # time.sleep(0.002)
        for bt in data:
                self.s.write(bt)
                time.sleep(0.00010)
        # time.sleep(0.002)
        # self.s.setDTR(True)  # RS485 input

    def __check_response(self, data):
        '''
        Check if received data contains valid modbus packet.
        '''
        if len(data) != 8:
            return False

        (slave, cmd, addr, size, crc) = unpack('>BBHHH', data)
        if self.__crc16(data) != 0:
            return False
        return True

    def __crc_byte(self, ch, crc):
        for i in range(8):
            if ((ch & 0x01) ^ (crc & 0x0001)) != 0x00:
                crc = (crc >> 1) ^ 0xA001
            else:
                crc = crc >> 1
            ch = ch >> 1
        return crc

    def __crc16(self, data):
        crc = 0xFFFF
        for d in data:
            crc = self.__crc_byte(ord(d), crc)
        return crc


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

    updater = MBUpdater(
        serial_port = port,
        slave = slave_address,
        baudrate=57600
    )

    start_time = time.time()

    # Unlock bootloader.
    print 'Sending secret key... ',
    updater.send_data(UNLOCK_ADDRESS, UNLOCK_SECRET)
    status, resp = updater.read_response()
    if not status:
        print '[Fail]'
        print 'BL is not unlocked. Wrong response!'
        print packet_print(resp)
        updater.close()
        exit(1)
    else:
        print '[OK]'

    # Get data in chunks
    fmw_data = get_firmware_as_list(fmw, chunksize=PAYLOAD_SIZE)
    print 'Firmware is {} B long.'.format(len(fmw_data) * PAYLOAD_SIZE)
    print 'First address 0x{:04X}.'.format(fmw_data[0][0])
    print 'Last address 0x{:04X}.'.format(fmw_data[-1][0])

    for segment in fmw_data:
        time.sleep(0.001)
        # Prepare data to send.
        address = segment[0]
        data = segment[1]
        updater.send_data(address, data)
        status, resp = updater.read_response()
        if not status:
            # Print send and received data -- for debugging.
            print '\nSending failed at address {:04X}!'.format(address)
            print packet_print(resp)
            break
        else:
            sys.stdout.write('.')
            sys.stdout.flush()

    print("\nTotal time: %s seconds" % (time.time() - start_time))
    updater.close()
