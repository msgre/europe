#ifndef __BL_RS485_H__
#define __BL_RS485_H__

#include <stdint.h>
#include <avr/pgmspace.h>
#include <util/delay.h>

#define RS485_ERR -1

#define rs485_puthex4(val) do{rs485_puthex2(((uint16_t)(val))>>8);rs485_puthex2(((uint16_t)(val))&0xFF);}while(0)
#define rs485_puthex8(val) do{rs485_puthex4(((uint32_t)(val))>>16);rs485_puthex4(((uint32_t)(val))&0xFFFF);}while(0)

#define rs485_output() (UART_DIR_PORT |= _BV(UART_DIR_PIN))
#define rs485_input() _delay_us(1000); UART_DIR_PORT &= ~_BV(UART_DIR_PIN)

void rs485_init(void);
void rs485_putc(char c);
void rs485_puts(char* s);
void rs485_putp(PGM_P s);
void rs485_puthex2(uint8_t val);
int16_t rs485_getc(void);

#endif