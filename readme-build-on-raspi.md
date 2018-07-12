# Norns Build on Raspberry Pi

## get started

### Download raspbian stretch lite 
https://www.raspberrypi.org/downloads/  
http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-12-01/

### write to sdcard 
https://etcher.io is a great tool for this

### setup for ssh and wifi
Add `ssh` and `wpa-supplicant.conf` files to boot partition of sd card so you can run headless.   
Details here https://caffinc.github.io/2016/12/raspberry-pi-3-headless/

## boot the pi and setup users
At the start it will be helpful to have the pi hooked up to an HDMI screen and a USB keyboard.

### raspi-config to setup user pw, network, etc
(For Localization: `All locations` will take a long time, maybe skip this and just select your own region )

    sudo raspi-config

`Change password: sleep`  
`Network > Hostname (norns)`  
`Network > Wifi (set SSID/password)`  
`Interfacing > SSH (on)`  
`Advanced > Expand File System`  
`Localization > (en-US-UTF8, US-UTF8)`  

exit, reboot  

    sudo reboot

### check IP address  
    ifconfig  

### change default user name 

    sudo passwd root  

logout, the login again as `root`  

    usermod -l we -d /home/we -m pi  
    groupmod --new-name we pi  

exit, login as `we`  

    sudo passwd -l root  

disable need for passwd with sudo  
(sudoers filename will vary - tab to autocomplete or `ls /etc/sudoers.d/` to check the filename)  

    sudo nano /etc/sudoers.d/010...  

`change 'pi' to 'we'`  

SSH to the pi with a new terminal. (use `ifconfig` to check IP if needed)
At this stage, using ssh to log in remotely w/ `we@norns/sleep` makes it easier to cut and paste things.

## run updates
    sudo apt-get update  

###  get git and other build dependencies
    sudo apt-get install vim git bc i2c-tools  
    sudo apt-get -y install libncurses5-dev  

### download dt-blob.bin ?
    wget https://monome.nyc3.digitaloceanspaces.com/dt-blob.bin  
    sudo mv dt-blob.bin /boot/  

## update / recompile kernel

Choose which linux source you want to use from the options below.  
_Note the *release* monome linux source is a older version that won't work on a Raspberry Pi 3b+ _  

**Note: The compile process will take about 90 mintues or more on a RasPi 3b**  

### get linux sources
**official RasPi Linux source (most recent)**  

	git clone --depth=1 https://github.com/raspberrypi/linux

**or monome norns linux source tree (norns-20171029-1 branch)**  

	git clone --depth=1 https://github.com/monome/linux

**or monome norns source tree for RasPi 3b+ compatibility (norns-4.14.y branch)**  

	git clone --depth=1 https://github.com/monome/linux/tree/norns-4.14.y


### for raspberry pi 2, pi 3, and compute module 3  

    cd linux
    KERNEL=kernel7
    make bcm2709_defconfig 

### configure  

    make menuconfig

### update the following  
> `Kernel Features —> Timer Frequenecy —> 1000hz`  
> `Kernel Features —> Preemption Model (Preemptible Kernel (Low-Latency Desktop))`  
> `CPU Power Management —> CPU Frequency scaling —> Default CPUFreq governor (performance)`  

### Compile Linux Sources  

    make -j4 zImage modules dtbs  
    sudo make modules_install  
    sudo cp arch/arm/boot/dts/*.dtb /boot/  
    sudo cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/  
    sudo cp arch/arm/boot/dts/overlays/README /boot/overlays/  
    sudo cp arch/arm/boot/zImage /boot/$KERNEL.img  

###reboot?

## setup norns image

    git clone https://github.com/monome/norns-image.git   
    cd norns-image  

**do not run setup.sh YET**

### norns setup config

    nano setup.sh  

comment out dhcp/interfaces copies so it does not hose your wifi when you install   
> `#sudo cp config/dhcpcd.conf /etc/dhcpcd.conf  `  
> `#sudo cp config/interfaces /etc/network/interfaces  `  
> `#sudo systemctl disable dhcpcd.service  `  

    nano config/norns-init.service   

comment out these lines for analog gain stage (put # in front, we dont want any i2cset)  
> `#ExecStart=-/usr/sbin/i2cset -y 1 0x28 0x00  `  
> `#ExecStart=-/usr/sbin/i2cset -y 1 0x28 0x40  `  

may also need to comment out Mixer line depending on your soundcard needs

    nano config/norns-jack.service  

change to your soundcard if needed. if you're using a usb soundcard, you'll probably need to change buffer size (-p)   

    nano config/norns-maiden.service   

change exec to `maiden` (not `maiden.arm`) Also get the file path right   

    ExecStart=/home/we/maiden/maiden -fd 3 -app ./app/build -data /home/we/dust -doc /home/we/norns/doc  

    nano scripts/init-norns.sh  

comment out i2cset for analog gain stages again  
> `#sudo i2cset -y 1 0x28 0x00  `  
> `#sudo i2cset -y 1 0x28 0x40  `  
	
may need to comment out Mixer line depending on your DAC setup  
	
### now run setup.sh  

    ./setup.sh


## install norns
follow instructions for apt-get, accept all defaults

    curl https://keybase.io/artfwo/pgp_keys.asc | sudo apt-key add -  
    echo "deb http://norns.catfact.net/ stretch main" | sudo tee /etc/apt/sources.list.d/norns.list  
    sudo apt update  
    sudo apt install --no-install-recommends jackd2  
    sudo apt install libmonome-dev libnanomsg-dev supercollider-language supercollider-server supercollider-dev liblua5.3-dev libudev-dev libevdev-dev liblo-dev libcairo2-dev liblua5.3-dev libavahi-compat-libdnssd-dev libasound2-dev dnsmasq hostapd  
    sudo apt install sc3-plugins ladspalist  
    sudo apt install usbmount  

clone norns source

    cd ~  
    git clone https://github.com/monome/norns   

for usb sync/etc via menu - change usbmount MountFlags in systemd-udevd.service   

    sudo nano /lib/systemd/system/systemd-udevd.service   

change `MountFlags=slave` to `MountFlags=shared`

### configure and compile norns  

    cd norns  
    ./waf configure  
    ./waf  

run sclang  

    sclang

## install supercollider (sc)  
    cd sc  
    ./install.sh  

more details at: https://github.com/monome/norns/blob/master/readme-setup.md

## install dust

    cd ~  
    git clone https://github.com/monome/dust  

# Maiden 

### install maiden  
(see https://github.com/monome/maiden/blob/dev/README.md)  

### install go

    wget https://storage.googleapis.com/golang/go1.9.linux-armv6l.tar.gz   
    sudo tar -C /usr/local -xzf go1.9.linux-armv6l.tar.gz   

    wget https://github.com/Masterminds/glide/releases/download/v0.13.1/glide-v0.13.1-linux-armv7.tar.gz   
    tar xvzf glide-v0.13.1-linux-armv7.tar.gz linux-armv7/glide  
    sudo mv linux-armv7/glide /usr/local/go/bin/  
    rm -rf linux-armv7 *.tar.gz  

### set go path
    export PATH=$PATH:/usr/local/go/bin (add to .profile too)  
    export GOPATH=$HOME/go (add to .profile too)  
    export GOBIN=/usr/local/go/bin/  

    go get -d github.com/monome/maiden  
    cd ~/go/src/github.com/monome/maiden  
    glide install  
    go build

    cd ~  
    ln -s ~/go/src/github.com/monome/maiden  


### test  
    ./maiden -debug -app app/build/ -data ~/norns/lua  

## Maiden UI install
https://github.com/monome/maiden/blob/dev/app/README.md

### first install node.js  

    curl -sL https://deb.nodesource.com/setup_8.x 1 | sudo -E bash -  
    sudo apt-get install -y nodejs  

    sudo npm install -g yarn  
    sudo npm install -g react-scripts  

    cd ~/go/src/github.com/monome/maiden/app/  

    yarn install  
    yarn build  

# Troubleshooting

### WiFi problem? (norns-init.service wont launch)  

run wifi scripts to set them up the first time  

    cd ~/norns  
    ./wifi.sh scan   
    ./wifi.sh on   

reboot


# DAC Audio Config

    sudo apt-get install -y i2c-tools   
    sudo apt-get install libi2c-dev   
    sudo apt-get install libasound-dev  
    sudo apt-get install alsa-utils  

    sudo nano /boot/config.txt  

`dtparam=audio=off `
`dtparam=i2c_arm=on`
`dtparam=spi=on`
`dtparam=i2s=on`
`dtoverlay=i2s-mmap`
`dtoverlay=rpi-proto`


    sudo nano /etc/modprobe.d/alsa-base.conf  

    sudo nano /usr/share/alsa/alsa.conf   

comment out  

`	#pcm.front cards.pcm.front`
	`#pcm.rear cards.pcm.rear`
	`#pcm.center_lfe cards.pcm.center_lfe`
	`#pcm.side cards.pcm.side`
	`#pcm.surround21 cards.pcm.surround21`
	`#pcm.surround40 cards.pcm.surround40`
	`#pcm.surround41 cards.pcm.surround41`
	`#pcm.surround50 cards.pcm.surround50`
	`#pcm.surround51 cards.pcm.surround51`
	`#pcm.surround71 cards.pcm.surround71`
	`#pcm.iec958 cards.pcm.iec958`
	`#pcm.hdmi cards.pcm.hdmi`
	`#pcm.modem cards.pcm.modem`
	`#pcm.phoneline cards.pcm.phoneline`
	
    sudo /etc/init.d/alsa-utils restart  

### get your device name  

    aplay -l   

    sudo nano /etc/asound.conf  

add

     pcm.!default  {  
       type hw card 0  
     }  

    ctl.!default {  
      type hw card 0  
    }  

### set mixer values

    amixer cset numid=13 on #Output Mixer HiFi  
    amixer cset numid=4 on #line in  
    sudo alsactl store  

    amixer cset numid=3 0%  

    aplay -l   


### blacklist onboard audio
edit  raspi-blacklist.conf 

    sudo nano /etc/modprobe.d/raspi-blacklist.conf  

Add
`blacklist snd_bcm2835`


# USB Audio Config

?????
### blacklist onboard audio

### Comment out options snd-usb-audio so it can load first
    sudo nano /lib/modprobe.d/aliases.conf
	`# options snd-usb-audio index=-2`

### get your device name
    aplay -l   

### use that with hw:(card name here) below

### Test if jackd is working  
    export JACK_NO_AUDIO_RESERVATION=1  
    jackd -R -P 95 -d alsa -d hw:PLAY -r 48000 -n 3 -p 128 -S -s  

from shreeswifty
you should have it @ 256 with 3 periods (-p flag) / try 2 periods if it makes noise


### edit jack configs here
    sudo nano ~/norns-image/config/jackdrc  
    sudo nano ~/norns-image/config/norns-jack.service  

### buttons-encoders

check  in /boot/config.txt if it loads the button/encoder overlay:

	# Buttons and encoders
	dtoverlay=norns-buttons-encoders


## NORNS MODS FOR WM8731 codec

edit norns/lua/menu.lua  
remove/comment lines 553,554   
USE LUA COMMENTS OR THINGS WILL BREAK  

     --if menu.alt == false then screen.text_right(norns.battery_percent)
     --else screen.text_right(norns.battery_current.."mA") end


norns/matron/src/hardware/screen.c
at line 138 - change to fb1

`void screen_init(void) {`
`surfacefb = cairo_linuxfb_surface_create("/dev/fb0");`
`if(surfacefb == NULL) { return; }`
`crfb = cairo_create(surfacefb);`


# SAMBA
See  https://oshlab.com/setting-samba-raspberry-pi/

    sudo apt-get install samba samba-common-bin  
    sudo nano /etc/samba/smb.conf  

>  `wins support = yes`  

>  `[norns]`  
>  `path=/home/we`  
>  `browseable=Yes`  
>  `writeable=Yes`  
>  `only guest=no`  
>  `create mask=0777`  
>  `directory mask=0777`  

then  

    sudo smbpasswd -a pi  

    sudo update-rc.d smbd enable  
    sudo update-rc.d nmbd enable  
    sudo service smbd restart  