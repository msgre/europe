#include <stdint.h>
#include <avr/boot.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>

#include "config.h"
#include "rs485.h"
#include "flash.h"

void write_page(uint16_t page, uint8_t *buff, uint16_t len) {
    #ifdef DEBUG_FLASH
    rs485_output();
    rs485_putp(PSTR("write_page   page="));
    rs485_puthex4(page);
    rs485_putp(PSTR("  buff="));
    rs485_puthex4((uint16_t)buff);
    rs485_putp(PSTR("  data_len="));
    rs485_puthex4(len);
    rs485_putc('\n');
    rs485_input();
    #endif

    // Firmware is too long!
    if ((page + len) > NRWW_START) {
        #ifdef DEBUG_FLASH
        rs485_output();
        rs485_putp(PSTR("FTL.\n"));
        rs485_input();
        #endif
        // Wait for watchdog reset.
        for(;;);
    }

    // Erase page.
    wdt_reset();
    eeprom_busy_wait();
    boot_page_erase(page);
    boot_spm_busy_wait();

    // TODO: odd-length code!
    for (int i = 0; i < len; i += 2) {
        uint16_t w = *buff++;
        w |= (*buff++) << 8;
        #ifdef DEBUG_FLASH_VERBOSE
        rs485_output();
        rs485_puthex4(w);
        rs485_input();
        #endif
        boot_page_fill(page + i, w);
        boot_spm_busy_wait();
    }

    #ifdef DEBUG_FLASH_VERBOSE
    rs485_output();
    rs485_putc('\n');
    rs485_input();
    #endif

    // Write data from temporary page buffer to flash memory.
    boot_page_write(page);
    boot_spm_busy_wait();
    boot_rww_enable();
}