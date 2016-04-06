import random

NEOPIXELS_ADDR = 0x1000
NEOPIXELS_COUNT = 12   # TODO: debug; in production it will be set to 50


class NeopixelsBase(object):
    """
    Base helper class.
    """

    def __init__(self, instrument, **kwargs):
        self.instrument = instrument
        for k in kwargs:
            setattr(self, k, kwargs[k])
        self.stop()

    def reset(self):
        self.counter = 0
        self.config()

    def start(self):
        self.reset()
        self.enable = True

    @property
    def is_running(self):
        return self.enable

    def stop(self):
        self.enable = False

    def step(self):
        if self.is_running:
            self.process()
            self.counter += 1

    def config(self):
        raise NotImplemented

    def process(self):
        raise NotImplemented

    @staticmethod
    def get_color(r, g, b, brightness):
        if brightness < 0:
            brightness = 0
        return (brightness << 12) | (r << 8) | (g << 4) | b

    def get_rand_rgb(self):
        c1 = random.randint(0, 15)
        if c1 < 11:
            c2 = random.randint(11, 15)
        else:
            c2 = random.randint(0, 10)
        if c1 + c2 > 15:
            c3 = random.randint(0, 7)
        else:
            c3 = random.randint(0, 15)
        out = [c1, c2, c3]
        random.shuffle(out)
        return out

    def set_color(self, led, color):
        self.instrument.write_registers(NEOPIXELS_ADDR + led - 1, [color])

    def set_colors(self, colors):
        self.instrument.write_registers(NEOPIXELS_ADDR, colors)

    def set_black(self):
        self.set_colors([0] * NEOPIXELS_COUNT)


class NeopixelsFlash(NeopixelsBase):
    """
    Flash effect. All LEDs turned on on randomly chosen color with high
    brightness, fade out to black during < 1s period.

    Used in countdown phase.
    """

    INITIAL_BRIGHTNESS = 10     # initial brightness value of all LEDs
    DELTA = 2                   # during each process() brightness will be decreased with this value until 0

    def config(self):
        self.rgb = self.get_rand_rgb()
        self.brightness = self.INITIAL_BRIGHTNESS

    def process(self):
        if self.brightness > -1:
            color = self.get_color(*self.rgb, brightness=self.brightness)
            self.set_colors([color] * NEOPIXELS_COUNT)
            self.brightness -= self.DELTA
        else:
            self.set_black()
            self.stop()


class NeopixelsBlink(NeopixelsBase):
    """
    Blink selected LED with given color and keep light on.

    Used during game for signalizing correct passing of tunnels (green color).
    In recap phase same effect is used for signalizing wrong tunnels (red color).
    """

    STATE_CYCLES = 2        # how many cycles through process() will LED keeps on/off state (during blinking phase)
    NUMBER_OF_BLINKS = 5    # number of blinks

    def config(self):
        self.state_duration = 3
        self.blink_counter = 0
        self.old_color = None
        self.led_buffer = [0] * NEOPIXELS_COUNT

    def process(self):
        if self.blink_counter < self.NUMBER_OF_BLINKS * 2 + 1:
            if (self.counter / self.STATE_CYCLES) % 2 == 0:
                _color = self.color
            else:
                _color = 0
            for led in self.leds:
                self.led_buffer[led - 1] = _color
            self.set_colors(self.led_buffer)
            if self.old_color != _color:
                self.old_color = _color
                self.blink_counter = self.blink_counter + 1
        else:
            for led in self.leds:
                self.led_buffer[led - 1] = self.color
                self.set_colors(self.led_buffer)
            self.stop()


class NeopixelsNoise(NeopixelsBase):
    """
    Make color noise (each Neopixel's LED is turn on randomly chosen color).
    Beware! There is no natural end of effect, it must be interrupted from
    outside.

    Used in countdown phase of game.
    """

    STATE_CYCLES = 2

    def config(self):
        self.led_buffer = []
        for i in range(NEOPIXELS_COUNT):
            color = self.get_color(*self.get_rand_rgb(), brightness=random.randint(0,7))
            self.led_buffer.append(color)

    def process(self):
        if self.counter % self.STATE_CYCLES == 0:
            random.shuffle(self.led_buffer)
        self.set_colors(self.led_buffer)


class NeopixelsBlank(NeopixelsBase):
    """
    Turn off all LED's.
    """
    def config(self):
        self.set_colors([0] * NEOPIXELS_COUNT)

    def process(self):
        self.stop()


class NeopixelsRainbow(NeopixelsBase):
    """
    Make rainbow effect (animated color transition).

    Used on intro page.
    """
    COLORLENGTH = NEOPIXELS_COUNT / 4
    FADE = 2

    def config(self):
        self.rainbow = [
            # [R,   G,   B],
            [0x8, 0x8, 0x8],  # white
            [0xF, 0x0, 0x0],  # red
            [0xF, 0x6, 0x0],  # orange
            [0x6, 0xF, 0x0],  # yellow
            [0x0, 0xF, 0x0],  # green
            [0x0, 0x6, 0xF],  # light blue
            [0x0, 0x0, 0xF],  # blue
            [0x6, 0x0, 0xF],  # violet
        ]
        self.led_buffer = [[0, 0, 0] for x in range(NEOPIXELS_COUNT)]
        self.j = 1
        self.k = 1

    def process(self):
        # Shift all values by one led.
        self.led_buffer.insert(0, list(self.led_buffer[0]))
        self.led_buffer = self.led_buffer[:-1]

        # Change color when colour length is reached.
        if self.k > self.COLORLENGTH:
            self.j += 1
            if self.j >= len(self.rainbow):
                self.j = 0
            self.k = 0
        self.k += 1

        # Fade first LED.
        if self.led_buffer[0][0] < (self.rainbow[self.j][0] - self.FADE):
            self.led_buffer[0][0] += self.FADE
        if self.led_buffer[0][0] > (self.rainbow[self.j][0] + self.FADE):
            self.led_buffer[0][0] -= self.FADE
        if self.led_buffer[0][1] < (self.rainbow[self.j][1] - self.FADE):
            self.led_buffer[0][1] += self.FADE
        if self.led_buffer[0][1] > (self.rainbow[self.j][1] + self.FADE):
            self.led_buffer[0][1] -= self.FADE
        if self.led_buffer[0][2] < (self.rainbow[self.j][2] - self.FADE):
            self.led_buffer[0][2] += self.FADE
        if self.led_buffer[0][2] > (self.rainbow[self.j][2] + self.FADE):
            self.led_buffer[0][2] -= self.FADE

        _buffer = [self.get_color(*i, brightness=4) for i in self.led_buffer]
        self.set_colors(_buffer)


if __name__ == '__main__':
    import sys
    import signal
    import time
    from minimalmodbus import Instrument

    if len(sys.argv) < 3:
        print('Usage: {} [EFFECT] [COM] [SLAVE] <baudrate=57600>'.format(sys.argv[0]))
        exit(1)

    effect = sys.argv[1]
    port = sys.argv[2]
    slave = int(sys.argv[3])
    try:
        baudrate = int(sys.argv[4])
    except Exception:
        baudrate = 57600

    instrument = Instrument(port, slave)
    instrument.serial.baudrate = baudrate
    instrument.serial.timeout = 1

    def signal_handler(signal, frame):
        print('Turning all LEDs off.')
        instrument.write_registers(0x1000, [0x0000] * NEOPIXEL_SIZE)
        sys.exit(0)
    signal.signal(signal.SIGINT, signal_handler)


    kwargs = {}
    if effect == 'flash':
        klass = NeopixelsFlash
    elif effect == 'blink':
        klass = NeopixelsBlink
        kwargs = {'leds': [1], 'color': 12345}
    elif effect == 'noise':
        klass = NeopixelsNoise
    elif effect == 'rainbow':
        klass = NeopixelsRainbow
    elif effect == 'blank':
        klass = NeopixelsBlank
    else:
        print('Unknown effect.')
        sys.exit(1)

    i = 0
    np = klass(instrument, **kwargs)
    np.start()
    while np.is_running:
        np.step()
        time.sleep(0.04)
        if i > 50:
            break
        i += 1
    np.set_black()
