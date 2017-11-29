# norns

## start

* attach mini-usb to computer usb
* insert wifi adapter
* hold key 1 for 3 seconds
* rear LED shows orange for power, white for disk activity

## setup

* linux: screen /dev/ttyACM0 115200
* mac: screen /dev/tty.ubserial(...) 115200 (fill in the serial number)

login is `pi` and password is `nnnn`

modify /etc/wpa_supplicant/wpa_supplicant.conf with your wifi info

`/etc/init.d/networking/restart`

then check your ip address to make sure `ifconfig`

feel free to disconnect from `screen` (crtl-a-z) 

## connect

`ssh pi@nnnn.local` (provided avahi is working, or use ip address)


## use

some startup scripts:

* `snd-unmute.sh` unmutes the soundcard
* `analog-gain-on.sh` turns up the analog gain stages
* `hp.sh` turns up the headphone
* `sudo gpio.sh` sets up the GPIO
* `rec-test.sh` is a simple arecord input test
* `fb.sh` installs framebuffer modules and tests the oled (ctrl-c to quit test)

you'll want to set up your git environment and then clone the norns repo.  

## poweroff

* presently you'll need to push the buttom button to hard-power-off the unit after running `sudo shutdown now` (this will be automatic in the future)

## battery

* the battery management driver is not yet installed, so there's no way to check how much battery you have left... beware! i also don't yet have an estimate on battery life, but i'm confident at low loads it will last quite a while-- but take care if unsaved work is happening on battery.
