#include <avr/io.h>
#include <avr/interrupt.h>

#include "config.h"
#include "rs485.h"

#define RS485_RX_BUFFER_MASK (RS485_BUFFER_SIZE - 1)
#define RS485_TX_BUFFER_MASK (RS485_BUFFER_SIZE - 1)

#if (RS485_BUFFER_SIZE & UART_RX_BUFFER_MASK)
#error RS485 buffer size has to be power of 2!
#endif

static char rs485_rx_buf[RS485_BUFFER_SIZE];
static volatile uint8_t rs485_rx_read = 0;
static volatile uint8_t rs485_rx_write = 0;

static char rs485_tx_buf[RS485_BUFFER_SIZE];
static volatile uint8_t rs485_tx_read = 0;
static volatile uint8_t rs485_tx_write = 0;

// Enable/disable TX interrupt (UDRE is empty, we can store next byte).
#define RS485_ENABLE_TX_INT()  (UCSR0B |= _BV(UDRIE0))
#define RS485_DISABLE_TX_INT()  (UCSR0B &= ~_BV(UDRIE0))

// Enable/disable TX complete interrupt (TX shift register is empty).
#define RS485_ENABLE_TXC_INT()  (UCSR0B |= _BV(TXCIE0))
#define RS485_DISABLE_TXC_INT()  (UCSR0B &= ~_BV(TXCIE0))

void rs485_init(void) {
    UBRR0 = BAUD_DOUBLE;
    // Double UART Transmission Speed
    UCSR0A = _BV(U2X0);
    // Enable RX & TX and RX interrupt
    UCSR0B = _BV(RXCIE0) | _BV(RXEN0) | _BV(TXEN0);
    // Config USART; 8N1
    UCSR0C = _BV(UCSZ01) | _BV(UCSZ00);

    // Pull-up
    DDRD &= ~_BV(PD0);
    PORTD |= _BV(PD0);

    // Set direction pin to output.
    RS485_DIR_DDR |= _BV(RS485_DIR_PIN);
    rs485_input();
}

/**
 * UART Receive interrupt. Save received character into RX buffer.
 */
ISR(USART_RX_vect) {
    uint8_t data = UDR0;
    rs485_rx_buf[rs485_rx_write] = data;
    rs485_rx_write = (rs485_rx_write+1) & (RS485_BUFFER_SIZE-1);
}

/**
 * UART UDR empty interrupt. Send first character from TX buffer and
 * leave rest of the data to Transmit interrupt.
 */
ISR(USART_UDRE_vect) {
    rs485_output();
    RS485_DISABLE_TX_INT();
    RS485_ENABLE_TXC_INT();
    // Send firt byte in buffer and leave rest of it to TX interrupt.
    rs485_tx_read = (rs485_tx_read + 1) & RS485_TX_BUFFER_MASK;
    UDR0 = rs485_tx_buf[rs485_tx_read];
}

/**
 * UART Transmit interrupt. Send TX buffer, then disable itself and change
 * RS485 direction to input.
 */
ISR(USART_TX_vect) {
    if(rs485_tx_write != rs485_tx_read) {
        // We have some data to send.
        rs485_tx_read = (rs485_tx_read + 1) & RS485_TX_BUFFER_MASK;
        UDR0 = rs485_tx_buf[rs485_tx_read];
    } else {
        // All data were send, disable this interrupt and change RS485 direction
        RS485_DISABLE_TXC_INT();
        rs485_input();
    }
}

void rs485_putc(char c) {
    uint8_t tmp_write = (rs485_tx_write + 1) & RS485_TX_BUFFER_MASK;

    // Wait for free space in buffer.
    while(tmp_write == rs485_tx_read);

    rs485_tx_buf[tmp_write] = c;
    rs485_tx_write = tmp_write;

    // Enable TX interrupt.
    RS485_ENABLE_TX_INT();
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

/**
 * Is there new character in UART buffer?
 */
uint8_t rs485_available(void) {
    return rs485_rx_write != rs485_rx_read;
}

/**
 * Wait until all data in TX buffer were send.
 */
void rs485_flush(void) {
    while(rs485_tx_write != rs485_tx_read);
}

/**
 * Get one char from UART.
 */
int16_t rs485_getc(void) {
    // No data in buffer.
    if(rs485_rx_read == rs485_rx_write) {
        return RS485_ERR;
    }

    char tmp = rs485_rx_buf[rs485_rx_read];
    rs485_rx_read = (rs485_rx_read + 1) & RS485_RX_BUFFER_MASK;
    return tmp;
}
