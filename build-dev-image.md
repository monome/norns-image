# BUILD

On norns, toggle bottom PCB switch from RUN to DISK. Connect norns to linux computer via usb cable.

* download raspbian lite image: https://www.raspberrypi.org/downloads/raspbian/
* set up usbboot: https://www.raspberrypi.org/documentation/hardware/computemodule/cm-emmc-flashing.md
* copy image to norns emmc, for example: `sudo dd if=2017-11-29-raspbian-stretch-lite.img of=/dev/sdb bs=4MiB conv=fsync status=progress`

Disconnect the boot USB port. Switch DISK back to RUN. Insert wifi.

Tape or weight down the power button. (Because a system file is not yet installed to keep the soft-power-switch on).

* connect to norns serial port: `screen /dev/ttyUSB0 115200`

The remaining commands happen within the terminal session:

login is "pi" with password "raspberry"

* `sudo raspi-config`

1. Change password: sleep
2. Network > Hostname (norns)
3. Network > Wifi (set SSID/password)
4. Interfacing > SSH (on)
5. Advanced > Expand File System
6. Localization > (set)
7. Exit, Reboot

- ctrl-A-Z will quit `screen`

re-login via `ssh pi@norns.local` (pw is now `sleep`)

continuing on within the ssh session:

run updates

* `sudo apt-get update`
* `sudo apt-get upgrade`
* `sudo apt-get install vim git bc i2c-tools`

update kernel

* get new kernel, put in linux computer `TODO`: get directly from gh

```
cd /
sudo tar -xvzf ~/kernel(...).tar.gz
sudo shutdown now
```

you can now remove the tape/weight from your power switch

change user name: we

1  `sudo passwd root`
2. logout, login as root
3. `usermod -l we -d /home/we -m pi`
4. `groupmod --new-name we pi`
5. exit, login as we
6. `sudo passwd -l root`

disable need for passwd with sudo

1. sudo nano /etc/sudoers.d/010_pi-nopasswd
2. change 'pi' to 'we'


clone norns-image for config setups

(this really needs to be done via `screen` not `ssh` because installing `network-manager` kills the wifi connection)

NOTE: `buster` branch of norns-image (to be commited to main)
```
git clone https://github.com/tehn/norns-image.git 
cd norns-image
./setup.sh
```

install norns 

- TODO: remove some of this below?
- just copy norns/maiden/dust release folders.
- installing supercollider is the main thing.
- tons of recommends ie for libcairo2-dev

```
curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -
echo "deb https://package.monome.org/ stretch main" | sudo tee /etc/apt/sources.list.d/norns.list
sudo apt update
sudo apt install --no-install-recommends jackd2 libjack-jackd2-dev
sudo apt install --no-install-recommends libmonome-dev libnanomsg-dev liblua5.3-dev libudev-dev libevdev-dev liblo-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev dnsmasq
sudo apt install --no-install-recommends supercollider-language supercollider-server supercollider-dev sc3-plugins
sudo apt install --no-install-recommends ladspalist usbmount
```

(clone your norns git)

```
cd norns
./waf configure
./waf
cd sc
./install.sh
``` 

note: you may need to run sclang once first (it will fail) before running sc/install.sh

reboot, norns should boot up.


set up `usbmount` for SYNC/etc via menu:

   (1) the 'usbmount' package is installed
       apt-get install usbmount

   (2) MountFlags has been tweaked in systemd-udevd.service
       https://www.raspberrypi.org/forums/viewtopic.php?t=205016
       (change MountFlags=slave to MountFlags=shared)
