# monome package apt
sudo cp config/norns.list /etc/apt/sources.list.d/

# hold packages we don't want to update
echo "raspberrypi-kernel hold" | sudo dpkg --set-selections

# install needed packages
sudo apt install hostapd midisport-firmware

# systemd
sudo cp --remove-destination config/norns-crone.service /etc/systemd/system/norns-crone.service
sudo cp --remove-destination config/norns-init.service /etc/systemd/system/norns-init.service
sudo cp --remove-destination config/norns-jack.service /etc/systemd/system/norns-jack.service
sudo cp --remove-destination config/norns-maiden.service /etc/systemd/system/norns-maiden.service
sudo cp --remove-destination config/norns-maiden.socket /etc/systemd/system/norns-maiden.socket
sudo cp --remove-destination config/norns-matron.service /etc/systemd/system/norns-matron.service
sudo cp --remove-destination config/norns.target /etc/systemd/system/norns.target
sudo systemctl enable norns.target

# motd
sudo cp config/motd /etc/motd

# wifi hotspot
sudo cp config/dnsmasq.conf /etc/dnsmasq.conf
sudo cp config/hostapd /etc/default/hostapd
sudo cp config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
sudo cp config/interfaces /etc/network/interfaces
sudo systemctl disable dhcpcd.service
sudo systemctl disable hostapd.service
sudo systemctl disable dnsmasq.service

# Plymouth
sudo systemctl mask plymouth-read-write.service
sudo systemctl mask plymouth-start.service
sudo systemctl mask plymouth-quit.service
sudo systemctl mask plymouth-quit-wait.service

# Apt timers
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer

# alsa state (handled by norns-init)
sudo systemctl mask alsa-restore.service
sudo systemctl mask alsa-state.service

# disable swap
sudo apt purge dphys-swapfile
sudo swapoff -a
sudo rm /var/swap

# speed up boot
sudo apt purge exim4-* nfs-common triggerhappy
sudo apt --purge autoremove


# ensure we don't override kernel option for 'ondemand' frequency
# governor
sudo systemctl mask raspi-config.service
