#ifndef __LG_TIMERS_H__
#define __LG_TIMERS_H__

#include <avr/io.h>

/**
 * Disable timer1 OCIE1A interrupt.
 */
#define timer1_disable() (TIMSK1 &= ~_BV(OCIE1A))

/**
 * Initialize and start 16b Timer1.
 */
void timer1_init(void);

/**
 * Return milliseconds since last MCU restart or timer1_reset().
 */
uint32_t timer1_get(void);

/**
 * Reset milliseconds counter.
 */
void timer1_reset(void);

/**
 * Set 8b Timer2. Prescaler 256 @8MHz ~ 8.192ms, @16MHz ~ 4.096ms.
 */
void timer2_start(void);
#define timer2_timeout() (TIFR2 & _BV(TOV2))

#endif