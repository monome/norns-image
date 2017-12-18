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

`sudo systemctl restart networking.service`

then check your ip address to make sure `ifconfig`

feel free to disconnect from `screen` (crtl-a-z) 

## connect

`ssh pi@nnnn.local` (provided avahi is working, or use ip address)


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
