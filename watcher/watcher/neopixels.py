import random

NEOPIXELS_ADDR = 0x1000
NEOPIXELS_COUNT = 18   # TODO: debug; in production it will be set to 50

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
        r = random.randint(11, 15)
        g = random.randint(11, 15)
        b = random.randint(11, 15)
        out = [r,g,b]
        out[random.randint(0,2)] = 0
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

    Example:

        np = NeopixelsFlash(instrument)
        np.start()
        while np.is_running:
            np.step()
            time.sleep(0.04)
        np.set_black()
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

    Example:

        # green blinking of one selected LED
        green = NeopixelsBlink.get_color(0, 15, 0, 5)
        np = NeopixelsBlink(instrument, leds=[1], color=green) # LED number 1
        np.start()
        while np.is_running:
            np.step()
            time.sleep(0.04)

        # red blinking of two LEDs
        red = color=NeopixelsBlink.get_color(15, 0, 0, 5)
        np = NeopixelsBlink(instrument, leds=[3, 10], color=red) # LEDs 3 and 10
        np.start()
        while np.is_running:
            np.step()
            time.sleep(0.04)

        # turn all LEDS off
        np.set_black()
    """

    STATE_CYCLES = 3        # how many cycles through process() will LED keeps on/off state (during blinking phase)
    NUMBER_OF_BLINKS = 5    # number of blinks

    def config(self):
        self.state_duration = 3
        self.blink_counter = 0
        self.old_color = None

    def process(self):
        if self.blink_counter < self.NUMBER_OF_BLINKS * 2 + 1:
            if (self.counter / self.STATE_CYCLES) % 2 == 0:
                _color = self.color
            else:
                _color = 0
            for led in self.leds:
                self.set_color(led, _color)
            if self.old_color != _color:
                self.old_color = _color
                self.blink_counter = self.blink_counter + 1
        else:
            for led in self.leds:
                self.set_color(led, self.color)
            self.stop()
