#ifndef __BL_FLASH_H__
#define __BL_FLASH_H__

/**
 * Programm memory at address 0x0000 contains reset vector. If this vector
 * is zero --> firmware is not valid.
 */
#define FLASH_CHECK_APP() (pgm_read_byte_near(0x0000) != 0x00)

/**
 * Write one page to flash memory.
 * Page is a byte address in flash, not a word address.
 */
void write_page(uint16_t page, uint8_t *buff, uint16_t len);

#endif