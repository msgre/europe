#ifndef __BL_TIMER_H__
#define __BL_TIMER_H__

#include <avr/io.h>

/**
 * Set 16b Timer1. Prescaler 256 @8MHz ~ 2 seconds, @16MHz ~ 1s.
 */
void timer1_start(void);
#define timer1_timeout() (TIFR1 & _BV(TOV1))


 /**
  * Set 8b Timer0. Prescaler 1024 @8MHz ~ 32ms, @16MHz ~ 16ms.
  */
void timer0_start(void);
#define timer0_timeout() (TIFR0 & _BV(TOV0))

#endif