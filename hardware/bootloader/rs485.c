#include <avr/io.h>

#include "timer.h"
#include "config.h"
#include "rs485.h"

void rs485_init(void) {
    UBRR0 = BAUD_DOUBLE;
    UCSR0A = _BV(U2X0);                    // Double UART Transmission Speed
    UCSR0B = _BV(RXEN0) | _BV(TXEN0);      // enable Rx & Tx
    UCSR0C = _BV(UCSZ01) | _BV(UCSZ00);    // config USART; 8N1

    // Pull-up
    DDRD &= ~_BV(PD0);
    PORTD |= _BV(PD0);

    // Set direction pin to output.
    UART_DIR_DDR |= _BV(UART_DIR_PIN);
    rs485_output();
}

void rs485_putc(char c) {
    while(!(UCSR0A & (1<<UDRE0)));
    UDR0=c;
    while(!(UCSR0A & (1<<TXC0)));
}
void rs485_puts(char* s) {
    while (*s) {
        rs485_putc(*s++);
    }
}

void rs485_putp(PGM_P s) {
    char c;
    while((c = pgm_read_byte_progmem(s++))) {
        rs485_putc(c);
    }
}

void rs485_puthex2(uint8_t val) {
    rs485_putc(hex(val>>4));
    rs485_putc(hex(val&0xF));
}

int16_t rs485_getc() {
    timer0_start();
    while(!(UCSR0A & _BV(RXC0))) {
        if(timer0_timeout()) return RS485_ERR; // Check if timer overflowed.
    }

    return UDR0;
}
