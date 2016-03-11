#ifndef __BL__MODBUS_H__
#define __BL__MODBUS_H__

/******************************************************************************/
/* This is simple implementation of modbus RTU protocol over serial line. Only*/
/* two modbus functions in slave mode are supported:                          */
/*   0x03 Read Holding Registers                                              */
/*   0x10 Preset Multiple Registers                                           */
/*                                                                            */
/* No exception support, timeout for reading data is based on 16b timer.      */
/******************************************************************************/

#include <stdint.h>
#include "config.h"

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
void modbus_init(uint8_t slave);

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
uint8_t modbus_send_pdu(modbus_pdu_t *pdu);

#ifdef DEBUG_MODBUS
void modbus_print_pdu(modbus_pdu_t *pdu);
#endif

#endif