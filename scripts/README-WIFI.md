# norns wifi scripts

These are some very basic scripts intended for the norns software to
manage one wifi connection at a time

## scan
./wifi.sh scan

## select
./wifi.sh select "My Wifi SSID" "wifi-password"

## stop
./wifi.sh off

## start
./wifi.sh on

(or helper script to switch over ssh)
./wifi-router.sh

## hotspot
./wifi.sh hotspot

(or helper script to switch over ssh)
./wifi-hotspot.sh

for hotspot setup, see image.txt

then to connect to the norns hotspot from arch linux laptop...
* `sudo wifi-menu`
(select norns)
password is nnnnnnnn
