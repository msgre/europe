#------------------------------------------------------------------------------
#------------------------------------------------------------ configuration ---

TARGET = main

#--------------------------------
# Hardware specific configuration
#--------------------------------

DEVICE = atmega328p
CLOCK = 16000000

# DEVICE = atmega88p
# CLOCK = 16000000

#----------------------------
# Programmer type and options
#----------------------------
PROGRAMMER = -c avrispmkii

#------
# Tools
#------
AVRDUDE = avrdude
CC = avr-gcc
OBJCOPY = avr-objcopy
AVR-SIZE = avr-size
OBJDUMP = avr-objdump

#------------------------------------------------------------------------------
#----------------------------------------- no user serviceable parts inside ---
.PHONY: all clean flash fuses
OBJECTS    = $(TARGET).o rs485.o modbus.o ws2812.o timers.o gpio.o
INCLUDES = -I.

PROGRAM = $(AVRDUDE) $(PROGRAMMER) -p $(DEVICE)
LDFLAGS += -Wl,--relax
LDFLAGS += -Wl,--gc-sections
CFLAGS += -std=gnu99
CFLAGS += -Os
CFLAGS += -mmcu=$(DEVICE)
CFLAGS += -DF_CPU=$(CLOCK)
CFLAGS += -Wall
CFLAGS += -Winline
CFLAGS += -Wstrict-prototypes
CFLAGS += -ffunction-sections
CFLAGS += -fdata-sections
CFLAGS += $(INCLUDES)
CFLAGS += -funsigned-char
CFLAGS += -fdiagnostics-color=always

FUSES = -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m

# default target
all: hex bin size

help:
	@echo
	@echo Help:
	@echo  make ....................... compile for ATMega328P
	@echo  make flash ................. flash to device
	@echo  make lst ................... export assembly from elf
	@echo  make clean ................. clean all

clean:
	rm -f $(TARGET).hex $(TARGET).elf $(TARGET).bin $(TARGET).lst $(OBJECTS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

flash:	all
	$(PROGRAM) -U flash:w:$(TARGET).hex:i

hex: $(TARGET).hex

bin: $(TARGET).bin

fuses:
	# $(PROGRAM) -e $(UNLOCK_FUSE)
	$(PROGRAM) $(FUSES)

lst: $(TARGET).elf
	$(OBJDUMP) -d $(TARGET).elf > $(TARGET).lst

$(TARGET).elf: $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

$(TARGET).hex: $(TARGET).elf
	rm -f $(TARGET).hex
	$(OBJCOPY) -O ihex $(TARGET).elf $(TARGET).hex

$(TARGET).bin: $(TARGET).elf
	rm -f $(TARGET).bin
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

size: $(TARGET).elf
	@echo "    SIZES"
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(text)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    FLASH : %5d bytes\n", $$a }'
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(data|bss)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    RAM   : %5d bytes\n", $$a }'
	@$(OBJDUMP) -h $^ | perl -MPOSIX -ne '/.(eeprom)\s+([0-9a-f]+)/ && do { $$a += eval "0x$$2" }; END { printf "    EEPROM: %5d bytes\n", $$a }'


