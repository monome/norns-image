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

1. Change password: nnnn
2. Network > Hostname (norns)
3. Network > Wifi (set SSID/password)
4. Interfacing > SSH (on)
5. Advanced > Expand File System
6. Localization > (all)
7. Exit, Reboot

* check IP address (`ifconfig`)

SSH to this IP with a new terminal from the linux computer (the terminal will work better).

* `sudo apt-get update`
* `sudo apt-get install vim git bc i2c-tools`

* get new kernel, compiled on the linux computer (see below) or from repo

below using: https://monome.nyc3.digitaloceanspaces.com/kernel-4.9.59-rt52-0.0.3.tar.gz

```
wget https://monome.nyc3.digitaloceanspaces.com/kernel-4.9.59-rt52-0.0.3.tar.gz
sudo tar -xvzf kernel-4.9.59-rt52-0.0.3.tar.gz -C /
```

get config.txt and dt-blob.bin, copy to boot

```
wget https://monome.nyc3.digitaloceanspaces.com/config.txt
sudo mv config.txt /boot/
wget https://monome.nyc3.digitaloceanspaces.com/dt-blob.bin
sudo mv dt-blob.bin /boot/
```

update `/boot/config.txt` and point `kernel` to the new kernel name, for example `kernel-4.9.59-rt52-0.0.3.img` (which was installed above)

reboot

`sudo reboot now`

you can now turn off the "always-on" switch

set up you git user/email and key (...)

clone norns-image for config setups

```
git clone https://github.com/tehn/norns-image.git 
cd norns-image
./setup.sh
```

install norns

```
curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -
echo "deb http://norns.catfact.net/ debian/" | sudo tee /etc/apt/sources.list.d/norns.list
sudo apt update
sudo apt install --no-install-recommends jackd2
sudo apt install libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-dev liblua5.3-dev libudev-dev libevdev-dev liblo-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev dnsmasq hostapd
sudo apt install sc3-plugins ladspalist
```

(clone your norns git)

```
cd norns
./waf configure
./waf
cd sc
./install.sh
``` 

reboot, norns should boot up.
