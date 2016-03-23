Demonstration of WebSocker communication between server side code connected 
directly to gate hardware and frontend Javascript code in browser.

This is not final version of watcher application. There are still commented
parts in code, because there are still plenty work in progress. But core 
functionality is working (websocket communication between browser/server,
communication with boards through ModBus).

# Setup

You will need NUC minipc with Ubuntu, ModBus adapter, few gates connected
together and http access to NUC.

Then follow this steps:

1) Build Docker image:

        build -t msgre/common:eu-watcher .

2) Run Docker image:

        docker run -ti --rm --name eu-watcher --device /dev/ttyUSB0 -p 8080:8080 msgre/common:eu-watcher

   You must provide access to physical ModBus adapter usualy mounted to 
   `/dev/ttyUSBX` and expose port 8080 to HTML demo page.

3) Open web browser
   Put there URL of NUC (in my case something like http://192.168.0.113:8080/).
   Open web developer javascript console and try press some button on keyboard
   gate (you should see published events from watcher). If you run
   `window.eu_session.publish('com.europe.start', [1]);` command in console
   you will enable gates. From now you should see also events about ball passing
   gates.

# Data format

Messages from `watcher`:

* `com.europe.keyboard`
  - you will receive code with button pressed
  - keyboard gate is technically same as normal gate; it's up to you how you
    configure physical buttons -- each button have own bit (see bellow)
* `com.europe.gate`
  - you will receiver object
  - keys represent gate code (1-16)
  - value represent crossed gates, each bit represent individual gate (see bellow)

Messages for `watcher`:

* `com.europe.effect`
  - turn on some of the LED effect on main gamebord
  - you must provide code representing mode
  - TODO: describe modes
* `com.europe.light`
  - switch on particular LED on main gamebord
  - you must provide 2 parameters: LED order number and color
  - addressed LED will blink 3 times and then stay in switch on state
* `com.europe.start`
  - start watching of game gates (from this time `com.europe.gate` events will 
    be published)
  - provide any value (it is ignored)
* `com.europe.stop`
  - stop watching of game gates
  - provide any value (it is ignored)

## Gate mapping

Each gate is capable of watching 6 gates. If you look on board from above,
you will see 6 connectors. They are mapped to individual bits of 16 bit value:
        
        [04] [08]
     [01] [02] [10] [20]

For example when ball pass gate 01, you will get value 1. When ball pass gate 20,
you will get value 32.
Board could give you combined value, for example if 2 mentioned gates are crossed 
in nearly same time, you will get value 33 (it is nonsense from game perspective,
but technically it is possible).

# Issues

On OSX Docker run inside Virtualbox machine, so there is one more layer to beat.
If you connect ModBus adapter into USB on Mac, you will see device like
`/dev/tty.usbserial-AJ03KXCG`. When I provide access for docker container
through `--device` switch, this device will be mapped to `/dev/ttyUSBX` in 
docker machine (to be sure, go into docker machine and check it: 
`docker-machine ssh` and `ls -l /dev | grep -i usb`), but you must allow access 
to USB device in VirtualBox IDE.

Even after this arrangement code was unstable (even with `--privileged` switch). 
For me it was easier move to physical NUC and develop code directly on production
hardware.
