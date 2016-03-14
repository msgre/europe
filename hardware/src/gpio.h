#ifndef __EU_GPIO_H__
#define __EU_GPIO_H__

// Onboard green LED.
#define LED_GRN PB5
#define LED_INIT() DDRB |= _BV(LED_GRN)
#define LED_ON()   PORTB |= _BV(LED_GRN)
#define LED_OFF()  PORTB &= ~_BV(LED_GRN)
#define LED_TOGGLE() PORTB ^= _BV(LED_GRN)

// Pin definitions for all 6 inputs.
#define IR_DDR  DDRC
#define IR_PIN  PINC
#define IR_PORT PORTC
#define IR_IOS  0x3F
#define IR_IO0  _BV(PC0)
#define IR_IO1  _BV(PC1)
#define IR_IO2  _BV(PC2)
#define IR_IO3  _BV(PC3)
#define IR_IO4  _BV(PC4)
#define IR_IO5  _BV(PC5)
#define IR_ALL  (IR_IO0 | IR_IO1 | IR_IO2 | IR_IO3 | IR_IO4 | IR_IO5)
// Set all pins as output and activate pullups.
#define IR_INIT() IR_DDR &= ~IR_ALL; IR_PORT |= IR_ALL


#define PCINT_ENABLE()  (PCICR |= _BV(PCIE1))
#define PCINT_DISABLE() (PCICR &= ~_BV(PCIE1))

/**
 * Initialize all inputs and enable pinchange interrupt.
 */
void gpio_init(void);

/**
 * Read states of all inputs and debouncing.
 */
uint8_t gpio_loop(void);

#endif