# norns hardware information

(TODO: add links)

CONFIG means /boot/config.txt

## SoC

Raspberry Pi Compute Module 3 (CM3)

quad core 1.2Ghz, 1GB RAM

onboard 4GB eMMC (rather than a SD card on consumer RPi models)

### USB Disk access

there is a switch accessible from the bottom of the board through a cutout. switch to DISK from RUN in order to execute the CM3 disk mode. see readme-usbdisk.md for further info.

## Power

Power is via USB mini, so 5V.

The provided USB power supply provides 5.25V which accounts for some voltage drop at high currents due to USB cable resistance. The supply can provide 2A, and the cable provided is high quality with 24g power lines. The supply is rated for 220V input so it can be used with a simple plug converter for international use.

### Battery

2250mAh lipo battery internally, with charge and monitoring circuitry.

- DRIVER: BQ27441-G1 (battery monitor)
- CONFIG: dtoverlay=bq27441

Internally the battery is mounted to the top of the enclosure and connected to the PCB with a standard 2-JST connector.

The i2c lines are connected to i2c0:

- PIN: SDA = GPIO2
- PIN: SCL = GPIO3

### Power switch

The primary 5V regulator is after the battery charge/path circuitry, so the battery will charge when plugged in even if the device isn't on.

The always-on power switch is by default off, which controls the state of the primary 5V regulator. This switch is OR'd with a soft power-on switch which is Key 1 (the upper left key), which is also tied to a GPIO so the CM3 can latch-up during power-on (pullup and default pin output configured with dt-blob.bin) but also allows the CM3 to control power-down on shutdown.

- GPIO: pin 12 is power-on. Held HIGH ensures the power stays on.
- DRIVER: GPIO-POWEROFF
- CONFIG: dtoverlay=gpio-poweroff:gpiopin=12,active_low=1

### Off (panic) switch

On the bottom of the unit (through a hole in the bottom plate) there's a kill switch which deactivates the main regulator. Don't use this unless you need to (ie total crash).

### Other regulators

The CM3 requires 3.3v and 1.8v which is handled by another regulator.

The analog (audio) section has its own LDO for a separated power plane and AGND.

### USB supply

Power is provided to USB devices directly from the USB power plug when present, bypassing any regulation (and hopefully reducing any additional noise).

When disconnected from external power the battery powers everything including the USB devices. The battery has a maximum discharge rate which may cause sudden shutdown if exceeded-- I'm finalizing the USB power path to solve this possible problem.


## Serial

There is a FT232 USB-serial IC connected to UART0 of the CM3 and exposed on the main USB power plug. Connecting to a computer means the computer will power the norns in addition to showing a USB-serial connection. Settings are 115200 8N1 and `screen` works fine.

- CONNECT (linux/mac): screen /dev/tty.usbserial??? 115200

No driver is needed for the CM3 but make sure the uart is enabled in config.

- CONFIG: enable_uart=1


## USB Hub

The USB connection of the CM3 is connected to a four port hub using the chip CY7C65634. Hub drivers are standard.

Power is limited to 900ma (likely to change) by a TPS2021 (also no driver needed). The WIFI usb port is not connected to the TPS (because it should never overpower, and we don't want it ever disconnected.)


## WIFI

A WIFI dongle is connected to a slightly recessed USB port which leaves the antenna exposed but does not appear as simply another USB port. The idea is that you never remove it. Remarkably it was much less expensive to buy an OEM WIFI dongle rather than put a transceiver directly onto the PCB.

It's a RTl8192/8188CUS, the driver is installed by default.


## Audio

### Codec

The audio codec is a CS4720.

- DRIVER: monome-snd
- CONFIG: dtoverlay=monome

The codec is externally clocked with a crystal (for no jitter), and the sample rate is fixed at 48k.

#### Pinout

- PIN: RESET = GPIO17
- PIN: SCLK = GPIO18
- PIN: FS = GPIO19
- PIN: DOUT = GPIO20
- PIN: DIN = GPIO21

### Inputs

The input jacks are configured for balanced or unbalanced. Input impedance is 10k.

### Outputs

The output jacks are configured for balanced or unbalanced. Output impedance is 590 ohm.

Output from the codec is connected to the headphone driver as well.

### Headphone driver

The headphone driver is a TPA6130A2. Volume is controlled via i2c with a simple protocol, so no driver is necessary, though I think one exists.

The i2c lines are connected to i2c0.


## Controls

### OLED

The OLED is a NHD-2.7-12864WDW3-M1

128 x 64 pixel
16-step grayscale, white LEDs

- DRIVER: ssd1322
- CONFIG: dtoverlay=ssd1322-spi

This OLED works with the fbtft library which is not mainline. It creates a framebuffer at /dev/fb1

Internally the OLED is connected with a flat ribbon cable that has a ZIF socket. I suggest disconnecting the ribbon on the PCB, not the OLED itself.

#### Pinout

The OLED is controlled via SPI (spi0 on the CM3) and a few GPIOs.

- PIN: SPI MISO = GPIO9
- PIN: SPI MOSI = GPIO10
- PIN: SPI SCK = GPIO11
- PIN: SPI CE0 = GPIO8
- PIN: RESET = GPIO6
- PIN: DC = GPIO5


### Keys and Encoders

There is a dt-overlay managing the keys and encoders.


#### Pinout

- PIN: KEY1 = GPIO31
- PIN: KEY2 = GPIO35
- PIN: KEY3 = GPIO39
- PIN: ENC1A = GPIO28
- PIN: ENC1B = GPIO29
- PIN: ENC2A = GPIO32
- PIN: ENC2B = GPIO33
- PIN: ENC3A = GPIO36
- PIN: ENC3B = GPIO37
