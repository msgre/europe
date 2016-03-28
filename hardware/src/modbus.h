#ifndef __BL__MODBUS_H__
#define __BL__MODBUS_H__

/******************************************************************************/
/* This is simple implementation of modbus RTU protocol over serial line. Only*/
/* two modbus functions in slave mode are supported:                          */
/*   0x03 Read Holding Registers                                              */
/*   0x10 Preset Multiple Registers                                           */
/*                                                                            */
/* No exception support, timeout for reading data is based on 8b timer.      */
/******************************************************************************/

#include <stdint.h>
#include "config.h"

#ifdef __BYTE_ORDER__
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define HTONS(x) ((uint16_t) (((uint16_t) (x) << 8) | ((uint16_t) (x) >> 8)))
#define HTONL(x) ((uint32_t) (((uint32_t) HTONS(x) << 16) | HTONS((uint32_t) (x) >> 16)))
#elif __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
#define HTONS(x) ((uint16_t) (x))
#define HTONL(x) ((uint32_t) (x))
#else
#error Byte order not supported!
#endif
#else
#error Byte order not defined!
#endif

/**
 * Flags for register changes.
 */
#define MODBUS_REGS_NOT_CHANGED 0
#define MODBUS_REGS_WRITE       1
#define MODBUS_REGS_READ        2

/**
 * Modbus slave address is defined by solder jumpers on DSP.
 * Initialize those pins as inputs with enabled pull-ups.
 */
#define MODBUS_ADDRESS_INIT() DDRD &= ~_BV(PD7); DDRB &= ~(_BV(PB0) | _BV(PB1) | _BV(PB2)); \
                              PORTD |= _BV(PD7); PORTB |= _BV(PB0) | _BV(PB1) | _BV(PB2)
#define MODBUS_ADDRESS_READ() ( ((PIND & _BV(PD7)) >> 7) | ((PINB & (_BV(PB0) | _BV(PB1) | _BV(PB2))) << 1) )

#define MODBUS_WRITE_REGS 0x10
#define MODBUS_READ_REGS  0x03

#define MODBUS_HEADER_SIZE  6

typedef enum {
    MODBUS_OK = 0,    // The message were sucessfully received.
    MODBUS_TIMEOUT,   // Timeout, no or incomplete message were received.
    MODBUS_WRONG_CRC, // Received message have wrong CRC.
    MODBUS_SLAVE      // Received message is for other slave on bus.
} modbus_status_e;

typedef struct {
    uint8_t slave;
    uint8_t function;
    uint16_t address;
    uint16_t wsize;
    uint8_t data[252]; // Maximum payload in modbus RTU
    //
    // uint16_t crc;
} modbus_pdu_t;

/**
 * Initialize modbus. Set slave address.
 */
void modbus_init(uint8_t slave, uint16_t *regs, uint8_t *regs_changes, uint8_t regs_len);

/**
 * Try to receive valid PDU for this slave.
 * This function is blocking, it will block until valid data
 * for this slave are received or until timeout. The timeout is
 * triggered by timer overflow.
 *
 * `pdu` is pointer to data structure where valid data will be stored.
 * `function` is number of function we are looking for.
 */
uint8_t modbus_recv_pdu(modbus_pdu_t *pdu);

/**
 * Send modbus response to master. PDU will contain this slave address.
 */
uint8_t modbus_send_pdu(modbus_pdu_t *pdu, uint8_t *data);

void modbus_loop(void);

#ifdef DEBUG_MODBUS
void modbus_print_pdu(modbus_pdu_t *pdu);
#endif

#endif