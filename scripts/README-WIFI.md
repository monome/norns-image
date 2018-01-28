# norns wifi scripts

These are some very basic scripts intended for the norns software to
manage one wifi connection at a time

## scan
./wifi-scan.sh

## select
../wifi-select.sh "My Wifi SSID" "wifi-password"

## start
./wifi-on.sh

## stop
./wifi-off.sh

## hotspot
setup:

sudo cp dnsmasq.conf /etc/dnsmasq.conf
sudo cp hostapd /etc/default/hostapd
sudo cp hostapd.conf /etc/hostapd/hostapd.conf
sudo cp dhcpcd.conf /etc/dhcpcd.conf
sudo cp interfaces /etc/network/interfaces
systemctl enable dhcpcd.service
systemctl enable hostapd.service
systemctl enable dnsmasq.service

then reboot...

then to connect to the norns hotspot from my arch linux laptop...

* `sudo wifi-menu`
(select norns)
password is nnnnnnnn
... then, on my laptop, I also need to:
* `sudo systemctl start dhcpcd`
