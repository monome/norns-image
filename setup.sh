#setup
sudo cp config/cmdline.txt /boot/
sudo cp config/jackdrc ~/.jackdrc
sudo cp config/rc.local /etc/

#wifi hotspot
sudo cp config/dnsmasq.conf /etc/dnsmasq.conf
sudo cp config/hostapd /etc/default/hostapd
sudo cp config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
sudo cp config/interfaces /etc/network/interfaces
sudo systemctl disable dhcpcd.service
sudo systemctl disable hostapd.service
sudo systemctl disable dnsmasq.service
