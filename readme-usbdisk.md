# USB Disk mode

If you soft-brick the CM3, you can attach it as a USB disk device and then change files to get it back into working order or read/write the entire disk image.

![](https://github.com/tehn/norns-image/raw/master/usbboot.jpg)

to open the cm3's emmc in usb disk mode:

- plug the usb boot in, connect to laptop (linux)
- change the power stay-on switch to the left (ON)
- power up the device by plugging in USB power (if the battery is unattached, otherwise it'll power-on when you change the switch)

## software

https://www.raspberrypi.org/documentation/hardware/computemodule/cm-emmc-flashing.md

summary:

```
sudo apt-get install libusb-1.0-0-dev
git clone --depth=1 https://github.com/raspberrypi/usbboot
cd usbboot
make
sudo ./rpiboot
```

a disk will show up in /dev/sd? (mine is normally `/dev/sdb`)

to copy image _to_ norns:

```
sudo dd if=image.img of=/dev/sdb bs=4M status=progress
sync
```

reverse of/if to copy _from_ norns
