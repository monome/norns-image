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


get jackdrc

```
wget https://monome.nyc3.digitaloceanspaces.com/.jackdrc
```

set up realtime

```
sudo groupadd realtime
sudo usermod -a -G realtime pi
```

add to `/etc/security/limits.d/99-realtime.conf`

```
@realtime - rtprio 99
@realtime - memlock unlimited
```

install
```
curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -
echo "deb http://norns.catfact.net/ debian/" | sudo tee /etc/apt/sources.list.d/norns.list
sudo apt update
sudo apt install libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-dev liblua5.3-dev libudev-dev libevdev-dev liblo-dev libcairo2-dev
```

(set up your git)

(clone your norns git)

norns
```
./waf configure
./waf
./sc/install.sh
```







---- STOP ----

## RT Kernel with drivers

### (Linux)

ref: https://www.raspberrypi.org/documentation/linux/kernel/building.md
ref: https://autostatic.com/2017/06/27/rpi-3-and-the-real-time-kernel/
find correct kernel: https://github.com/raspberrypi/linux/commits?author=gregkh
patch: https://www.kernel.org/pub/linux/kernel/projects/rt/4.9/

```
git clone https://github.com/raspberrypi/tools.git
git clone https://github.com/raspberrypi/linux.git -b rpi-4.9.y
wget https://www.kernel.org/pub/linux/kernel/projects/rt/4.9/patch-4.9.76-rt61.patch.xz
wget https://raw.githubusercontent.com/fedberry/kernel/master/usb-dwc_otg-fix-system-lockup-when-interrupts-are-threaded.patch
cd linux
git checkout 7bbc6ca4887794cc44b41412a35bdfbe0cbd1c50
make bcm2709_defconfig
export KERNEL=kernel7
export ARCH=arm
export CROSS_COMPILE=~/work/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-
export CONCURRENCY_LEVEL=$(nproc)
xzcat ../patch-4.9.76-rt61.patch.xz | patch -p1
patch -i ../usb-dwc_otg-fix-system-lockup-when-interrupts-are-threaded.patch -p1

monome-snd patches
fbtft patches

make menuconfig
	Kernel Features - Preemption Model - Fully Preemptible Kernel (RT)
	Device drivers - Power supply class support - BQ27xxx battery driver (+I2C)
	Device Drivers > Sound Card Support > ALSA > ALSA for SoC > Support for monome-snd
make clean
scripts/config --disable DEBUG_INFO
make
mkdir ../install
make modules_install INSTALL_MOD_PATH=../install/
cp arch/arm/boot/zImage ../install/
cp arch/arm/boot/dts/*.dtb ../install/
mkdir ../install/overlays
cp arch/arm/boot/dts/overlays/*.dtb* ../install/overlays/
cp arch/arm/boot/dts/overlays/README ../install/overlays/
cd ..
tar czvf image.tgz install
```
