# BUILD

Headings in parens indicate which machine the operation happens on. (Linux) means a fast computer with linux, I'm using Ubuntu on a 2011 Macbook Air. (Norns) happens on the norns hardware.

## Raspbian

Disassemble norns, connect both USB cables to linux computer (to internal and external norns ports), toggle internal stay-on power switch (near battery connector).

### (Linux)

* lite image: https://www.raspberrypi.org/downloads/raspbian/ (2017-11-29)
* usbboot: https://www.raspberrypi.org/documentation/hardware/computemodule/cm-emmc-flashing.md
* copy image to norns emmc: `sudo dd if=2017-11-29-raspbian-stretch-lite.img of=/dev/sdb bs=4MiB conv=fsync'

Disconnect the boot USB port. Reset the norns with the bottom switch. Insert wifi.

* connect to norns serial port: `screen /dev/ttyUSB0 115200`

### (Norns)

login is "pi" with password "raspberry"

* `sudo raspi-config`

1. Change password: sleep
2. Network > Hostname (norns)
3. Network > Wifi (set SSID/password)
4. Interfacing > SSH (on)
5. Advanced > Expand File System
6. Localization > (all)
7. Exit, Reboot

* check IP address (`ifconfig`)

change user name: we

1. `sudo passwd root`
2. logout, login as root
3. `usermod -l we -d /home/we -m pi`
4. `groupmod --new-name we pi`
5. exit, login as we
6. `sudo passwd -l root`

disable need for passwd with sudo

1. sudo nano /etc/sudoers.d/010...
2. change 'pi' to 'we'

SSH to this IP with a new terminal from the linux computer (the terminal will work better).

* `sudo apt-get update`
* `sudo apt-get install vim git bc i2c-tools`

* get new kernel, compiled on the linux computer (see below) or from repo

below using: kernel-4.9.59-rt52-0.0.4.tar.gz

```
wget https://monome.nyc3.digitaloceanspaces.com/kernel-4.9.59-rt52-0.0.4.tar.gz
sudo tar -xvzf kernel-4.9.59-rt52-0.0.4.tar.gz -C /
```

config.txt is in the kernel zip

get dt-blob.bin, copy to boot

```
wget https://monome.nyc3.digitaloceanspaces.com/dt-blob.bin
sudo mv dt-blob.bin /boot/
```

reboot

`sudo reboot now`

you can now turn off the "always-on" switch

clone norns-image for config setups

```
git clone https://github.com/tehn/norns-image.git 
cd norns-image
./setup.sh
```

install norns

```
curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -
echo "deb https://package.monome.org/ stretch main" | sudo tee /etc/apt/sources.list.d/norns.list
sudo apt update
sudo apt install --no-install-recommends jackd2 libjack-jackd2-dev
sudo apt install libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-supernova supercollider-dev liblua5.3-dev libudev-dev libevdev-dev liblo-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev dnsmasq hostapd
sudo apt install sc3-plugins ladspalist
sudo apt install usbmount
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
