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

update kernel

* get new kernel, put in linux computer `TODO`: get directly from gh

```
sudo tar -xvzf ~/kernel(...).tar.gz
sudo cp -R boot/* /boot/
sudo cp -R lib/* /lib/
sudo shutdown now
```

you can now remove the tape/weight from your power switch

run updates

* `sudo apt-get update`
* `sudo apt-get upgrade`
* `sudo apt-get install vim git bc i2c-tools`

change user name: we

1.  `sudo passwd root`
2. logout, login as root
3. `usermod -l we -d /home/we -m pi`
4. `groupmod --new-name we pi`
5. exit, login as we
6. `sudo passwd -l root`

disable need for passwd with sudo

1. sudo vim /etc/sudoers.d/010_pi-nopasswd
2. change 'pi' to 'we'
3. force write with :w!


clone norns-image for config setups

(this really needs to be done via `screen` not `ssh` because installing `network-manager` kills the wifi connection)

NOTE: `buster` branch of norns-image (to be commited to main)
```
git clone https://github.com/tehn/norns-image.git 
cd norns-image
./setup.sh
```

DEV
```
sudo apt-get install libevdev-dev liblo-dev libudev-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev libncurses5-dev libncursesw5-dev libsndfile1-dev libjack-dev libboost-dev libnanomsg-dev
sudo apt install --no-install-recommends jackd2 libjack-jackd2-dev
sudo apt install --no-install-recommends ladspalist usbmount
```

libmonome
```
git clone https://github.com/monome/libmonome.git
./waf configure
./waf
sudo ./waf install
```

supercollider
```
sudo apt-get install libsamplerate0-dev libsndfile1-dev libasound2-dev libavahi-client-dev \
    libreadline-dev libfftw3-dev libudev-dev libncurses5-dev cmake git
git clone https://github.com/supercollider/supercollider.git

cmake     -DCMAKE_BUILD_TYPE=Release \
    -DNATIVE=1 \
    -DSSE=0 \
    -DSSE2=0 \
    -DENABLE_TESTSUITE=0 \
    -DCMAKE_SKIP_RPATH=1 \
    -DLIBSCSYNTH=0 \
    -DSUPERNOVA=0 \
    -DSC_WII=0 \
    -DSC_IDE=0 \
    -DSC_QT=0 \
    -DSC_ED=0 \
    -DSC_EL=0 \
    -DSC_VIM=1 \
    -DNO_X11=ON -DSC_QT=OFF
```

sc3-plugins


install norns 

- just copy norns/maiden/dust release folders.

(clone your norns git)

```
cd norns
./waf configure
./waf
cd sc
./install.sh
``` 

note: you may need to run sclang once first (it will fail) before running `norns/sc/install.sh`

reboot, norns should boot up.
