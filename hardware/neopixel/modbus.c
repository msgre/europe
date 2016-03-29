#include <string.h>
#include <util/crc16.h>
#include <util/delay.h>

#include "rs485.h"
#include "modbus.h"
#include "timers.h"

#include "gpio.h"

// Minimum silent time between two modbus RTUs is 3.5x character length.
// The character time is (11bits * 3.5) / baudrate.
#define MODBUS_SILENT_PERIOD ((11*4)/(BAUD_RATE/100000+1))
#define MODBUS_DELAY() for(uint16_t i = 0; i < MODBUS_SILENT_PERIOD; i++) { _delay_us(10); }

static volatile uint8_t slave_address = 0;
static volatile uint8_t mb_regions_len = 0;
static mb_registers_t *mb_regions;
static modbus_pdu_t mb_pdu;

void modbus_init(uint8_t slave, mb_registers_t *regions, uint8_t regions_len) {
    slave_address = slave;
    mb_regions = regions;
    mb_regions_len = regions_len;

    // Set `change flag` for all registers to `not changed`.
    for(uint8_t i = 0; i < mb_regions_len; i++) {
        memset(
            mb_regions[i].change,
            MODBUS_REGS_NOT_CHANGED,
            mb_regions[i].size
        );
    }
}

uint8_t modbus_recv_pdu(modbus_pdu_t *pdu) {
    uint16_t i = 0;
    uint16_t pdu_length = MODBUS_HEADER_SIZE + 2; // Header + CRC
    uint16_t crc = 0xFFFF;
    int16_t ch;
    uint8_t *p_pdu = (uint8_t *)pdu;

    #ifdef DEBUG_MODBUS_VERBOSE
    rs485_putc('a');
    #endif

    timer2_start();
    while(i < pdu_length) {
        if(!rs485_available()) {
            if(timer2_timeout()) {
                #ifdef DEBUG_MODBUS_VERBOSE
                rs485_putc('t');
                #endif
                return MODBUS_TIMEOUT;
            }

            continue;
        }

        ch = rs485_getc();
        p_pdu[i] = (uint8_t)ch;
        i++;
        // Update CRC.
        crc = _crc16_update(crc, (uint8_t)ch);

        // Did we already received complete modbus header?
        if(i == MODBUS_HEADER_SIZE) {
            // If function is 0x10 (write regs), update pdu_length.
            if(pdu->function == MODBUS_WRITE_REGS) {
                pdu_length += (HTONS(pdu->wsize) * 2) + 1;
            }

            #ifdef DEBUG_MODBUS_VERBOSE
            rs485_putc('l');
            #endif
        }

        #ifdef DEBUG_MODBUS_VERBOSE
        rs485_putc('.');
        #endif

        timer2_start();
    } // end while


    #ifdef DEBUG_MODBUS_VERBOSE
    rs485_putc('c');
    #endif

    // Check CRC.
    if(crc != 0x0000) {
        return MODBUS_WRONG_CRC;
    }

    // Check if message is for this slave.
    if(pdu->slave != slave_address) {
        return MODBUS_SLAVE;
    }

    // Fix endianness if needed.
    pdu->address = HTONS(pdu->address);
    pdu->wsize = HTONS(pdu->wsize);


    #ifdef DEBUG_MODBUS_VERBOSE
    rs485_putc('z');
    #endif

    return MODBUS_OK;
}

uint8_t modbus_send_pdu(modbus_pdu_t *pdu, uint8_t *data) {
    uint16_t crc = 0xFFFF;

    rs485_putc(slave_address);
    crc = _crc16_update(crc, slave_address);

    rs485_putc(pdu->function);
    crc = _crc16_update(crc, pdu->function);

    if(pdu->function == MODBUS_WRITE_REGS) {
        rs485_putc(pdu->address >> 8);
        rs485_putc(pdu->address & 0x00FF);
        crc = _crc16_update(crc, pdu->address >> 8);
        crc = _crc16_update(crc, pdu->address & 0x00FF);

        rs485_putc(pdu->wsize >> 8);
        rs485_putc(pdu->wsize & 0x00FF);
        crc = _crc16_update(crc, pdu->wsize >> 8);
        crc = _crc16_update(crc, pdu->wsize & 0x00FF);
    } else {
        uint8_t count = pdu->wsize*2;
        rs485_putc(count);
        crc = _crc16_update(crc, count);
        for(uint8_t i = 0; i < count; i+=2) {
            rs485_putc(data[i+1]);
            rs485_putc(data[i]);
            crc = _crc16_update(crc, data[i+1]);
            crc = _crc16_update(crc, data[i]);
        }
    }

    rs485_putc(crc & 0x00FF);
    rs485_putc(crc >> 8);
    return 0;
}

void modbus_loop(void) {
    uint8_t err = modbus_recv_pdu(&mb_pdu);
    if(err != MODBUS_OK) {
        return;
    }

    // Find correct region
    mb_registers_t *region = NULL;
    for(uint8_t i = 0; i < mb_regions_len; i++) {
        // Check start address.
        if(mb_pdu.address < mb_regions[i].start) {
            continue;
        }

        // Check end address of this region.
        if(mb_pdu.address > (mb_regions[i].start + mb_regions[i].size)) {
            continue;
        }

        region = &(mb_regions[i]);
        break;
    }

    if(region == NULL) {
        // We did not find any region where given address belongs.
        // TODO: send some Modbus exception?
        return;
    }

    uint16_t data_offset = mb_pdu.address - region->start;
    if(mb_pdu.function == MODBUS_WRITE_REGS) {
        memcpy(region->registers+data_offset, mb_pdu.data+1, mb_pdu.data[0]);
        // Mark all received registers as changed.
        for(uint8_t i = 0; i < mb_pdu.wsize; i++) {
            region->change[data_offset+i] = MODBUS_REGS_WRITE;
        }
        // Wait before response.
        // TODO: non blocking waiting!
        MODBUS_DELAY();
        // Send modbus response.
        modbus_send_pdu(&mb_pdu, NULL);
    } else if(mb_pdu.function == MODBUS_READ_REGS) {
        // Wait before response.
        // TODO: non blocking waiting!
        MODBUS_DELAY();
        // Send modbus response.
        for(uint8_t i = 0; i < mb_pdu.wsize; i++) {
            region->change[data_offset+i] = MODBUS_REGS_READ;
        }
        modbus_send_pdu(&mb_pdu, (uint8_t *)(region->registers+data_offset));
    }
}

#ifdef DEBUG_MODBUS
#include <avr/pgmspace.h>

void modbus_print_pdu(modbus_pdu_t *pdu) {
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
}
#endif
