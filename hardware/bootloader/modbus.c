#include <util/crc16.h>

#include "rs485.h"
#include "modbus.h"

static volatile uint8_t slave_address = 0;

void modbus_init(uint8_t slave) {
    slave_address = slave;
}

uint8_t modbus_recv_pdu(modbus_pdu_t *pdu) {
    uint16_t i = 0;
    uint16_t crc = 0xFFFF;
    int16_t ch;
    uint8_t *p_pdu = (uint8_t *)pdu;

    rs485_input();

    #ifdef DEBUG_MODBUS_VERBOSE
    rs485_output();
    rs485_putc('a');
    rs485_input();
    #endif

    while(1) {
        if((ch = rs485_getc()) == RS485_ERR) {
            break;
        }

        p_pdu[i] = (uint8_t)ch;
        crc = _crc16_update(crc, (uint8_t)ch);
        i++;

        #ifdef DEBUG_MODBUS_VERBOSE
        rs485_output();
        rs485_putc('.');
        rs485_input();
        #endif
    } // end while

    // Shortest modbus packet should contain at least 6 bytes -> modbus header.
    if(i < 6) {
        return MODBUS_TIMEOUT;
    }

    // Check CRC. Valid modbus message should have zero CRC.
    if(crc != 0x0000) {
        return MODBUS_WRONG_CRC;
    }

    // Check if message is for us.
    if(pdu->slave != slave_address) {
        return MODBUS_SLAVE;
    }

    // Fix endianness if needed.
    pdu->address = HTONS(pdu->address);
    pdu->wsize = HTONS(pdu->wsize);

    return MODBUS_OK;
}

uint8_t modbus_send_pdu(modbus_pdu_t *pdu) {
    uint16_t crc = 0xFFFF;

    rs485_output();

    rs485_putc(slave_address);
    crc = _crc16_update(crc, slave_address);

    rs485_putc(pdu->function);
    crc = _crc16_update(crc, pdu->function);

    rs485_putc(pdu->address >> 8);
    rs485_putc(pdu->address & 0x00FF);
    crc = _crc16_update(crc, pdu->address >> 8);
    crc = _crc16_update(crc, pdu->address & 0x00FF);

    rs485_putc(pdu->wsize >> 8);
    rs485_putc(pdu->wsize & 0x00FF);
    crc = _crc16_update(crc, pdu->wsize >> 8);
    crc = _crc16_update(crc, pdu->wsize & 0x00FF);

    rs485_putc(crc & 0x00FF);
    rs485_putc(crc >> 8);

    rs485_input();
    return 0;
}

#ifdef DEBUG_MODBUS
#include <avr/pgmspace.h>

void modbus_print_pdu(modbus_pdu_t *pdu) {
    rs485_output();
    rs485_putp(PSTR("S:"));
    rs485_puthex2(pdu->slave);
    rs485_putp(PSTR(", F:"));
    rs485_puthex2(pdu->function);
    rs485_putp(PSTR(", A:"));
    rs485_puthex4(pdu->address);
    rs485_putp(PSTR(", S:"));
    rs485_puthex4(pdu->wsize);
    rs485_putp(PSTR(", D:"));
    for(uint16_t i = 0; i < pdu->wsize * 2; i++) {
        rs485_puthex2(pdu->data[i]);
        rs485_putc(':');
    }

    rs485_putc('\n');
    rs485_input();
}
#endif
