# hold packages we don't want to update
echo "raspberrypi-kernel hold" | sudo dpkg --set-selections

# install needed packages
sudo apt install --no-install-recommends network-manager dnsmasq-base midisport-firmware samba

# systemd
sudo mkdir -p /etc/systemd/system.conf.d
sudo cp --remove-destination config/10-default-env-vars.conf /etc/systemd/system.conf.d/10-default-env-vars.conf
sudo rm /etc/systemd/system/norns-crone.service
#sudo cp --remove-destination config/norns-crone.service /etc/systemd/system/norns-crone.service
sudo rm /etc/systemd/system/norns-supernova.service
#sudo cp --remove-destination config/norns-supernova.service /etc/systemd/system/norns-supernova.service
sudo cp --remove-destination config/norns-sclang.service /etc/systemd/system/norns-sclang.service
sudo cp --remove-destination config/norns-jack.service /etc/systemd/system/norns-jack.service
sudo cp --remove-destination config/norns-maiden.service /etc/systemd/system/norns-maiden.service
sudo cp --remove-destination config/norns-maiden.socket /etc/systemd/system/norns-maiden.socket
sudo rm /etc/systemd/system/norns-matron.service
#sudo cp --remove-destination config/norns-matron.service /etc/systemd/system/norns-matron.service
sudo cp --remove-destination config/norns-main.service /etc/systemd/system/norns-main.service
sudo cp --remove-destination config/norns-watcher.service /etc/systemd/system/norns-watcher.service
sudo cp --remove-destination config/norns.target /etc/systemd/system/norns.target
sudo cp --remove-destination config/55-maiden-systemctl.pkla /etc/polkit-1/localauthority/50-local.d/55-maiden-systemctl.pkla
sudo systemctl enable norns.target

# motd
sudo cp config/motd /etc/motd

# profile
sudo cp config/10-default-env-vars.sh /etc/profile.d/10-default-env-vars.sh

# bashrc
sudo cp config/bashrc /home/we/.bashrc

# samba
(echo "sleep"; echo "sleep") | sudo smbpasswd -s -a we
sudo cp config/smb.conf /etc/samba/
sudo /etc/init.d/samba restart


# Wifi
# Use the upstream rtl8192cu driver instead of the problematic realtek 8192cu driver
sudo rm -f /etc/modprobe.d/blacklist-rtl8192cu.conf
sudo cp config/blacklist-8192cu.conf /etc/modprobe.d/
# NetworkManager config
sudo cp config/interfaces /etc/network/interfaces
sudo cp config/network-manager/100-disable-wifi-mac-randomization.conf /etc/NetworkManager/conf.d/
sudo cp config/network-manager/101-logging.conf /etc/NetworkManager/conf.d/
sudo cp config/network-manager/200-disable-nmcli-auth.conf /etc/NetworkManager/conf.d/
sudo systemctl disable pppd-dns.service

# limit log sizes
sudo cp config/journald.conf /etc/systemd/
sudo cp config/logrotate.conf /etc/
sudo cp config/rsyslog.conf /etc/
sudo cp config/rsyslog /etc/rsyslog.d/

# Plymouth
# Get rid of our old masked plymouth units
sudo systemctl unmask plymouth-read-write.service
sudo systemctl unmask plymouth-start.service
sudo systemctl unmask plymouth-quit.service
sudo systemctl unmask plymouth-quit-wait.service
sudo apt purge plymouth

# Apt timers
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer

# alsa state (handled by norns-init)
sudo systemctl mask alsa-restore.service
sudo systemctl mask alsa-state.service

# disable bluetooth modem (bullseye)
sudo systemctl mask hciuart.service

# disable swap
sudo apt purge dphys-swapfile
sudo swapoff -a
sudo rm /var/swap

# speed up boot
sudo apt purge exim4-* nfs-common triggerhappy

# ensure we don't override kernel option for 'ondemand' frequency
# governor
sudo systemctl mask raspi-config.service

# set alsa volume and store
amixer --device hw:sndrpimonome set Master 100% on
sudo alsactl store

# uninstall packages we don't need
sudo apt purge libraspberrypi-doc modemmanager

# cleanup
sudo apt --purge -y autoremove
