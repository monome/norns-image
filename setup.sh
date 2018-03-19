#setup
sudo cp config/cmdline.txt /boot/
sudo cp config/jackdrc ~/.jackdrc
sudo cp config/rc.local /etc/

#realtime group
sudo groupadd realtime
sudo usermod -a -G realtime pi
sudo cp config/99-realtime.conf /etc/security/limits.d/99-realtime.conf

#wifi hotspot
sudo cp config/dnsmasq.conf /etc/dnsmasq.conf
sudo cp config/hostapd /etc/default/hostapd
sudo cp config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
sudo cp config/interfaces /etc/network/interfaces
sudo systemctl disable dhcpcd.service
sudo systemctl disable hostapd.service
sudo systemctl disable dnsmasq.service
