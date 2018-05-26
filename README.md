# norns

## start

* attach mini-usb to computer usb
* insert wifi adapter
* hold key 1 for 3 seconds
* rear LED shows orange for power, white for disk activity

## serial connection

* linux: `screen /dev/ttyACM0 115200`
* mac: `screen /dev/tty.ubserial(...) 115200` (fill in the serial number)
* windows: install [Putty](https://www.putty.org/) and connect with connection type "Serial" to serial line COM(...) and speed: 115200 (fill in comport number)

login is `we` and password is `sleep`

disconnect from `screen` (crtl-a-z) 

## hotspot connect

norns boots by default in hotspot mode.  Connect to norns' wifi hotspot: SSID=norns PSK=nnnnnnnn

`ssh we@nnnn.local` (provided avahi is working) `ssh we@172.24.1.1` (if avahi is not working)

## switch norns wifi connection to external wifi network
* `wifi.sh scan`
* `wifi.sh select "My Wifi SSID" "wifi-password"`
* `wifi-router.sh` (helper script to reconfigure network whilst ssh-ed in)
* `wifi-hotspot.sh` (switches back to hotspot mode whilst ssh-ed in)

## use

audio i/o test script:

* `rec-test.sh` is a simple arecord input test

you'll want to set up your git environment and then clone the norns repo.  

then:

```
cd norns
./crone.sh > /dev/null &
./matron.sh > /dev/null &
maiden/maiden
```
