# USB Disk mode

If you soft-brick the CM3, you can attach it as a USB disk device and then change files to get it back into working order or read/write the entire disk image.

![](https://github.com/tehn/norns-image/raw/master/usbboot.jpg)

to open the cm3's emmc in usb disk mode:

- plug the usb boot in, connect to laptop (linux)
- change the power stay-on switch to the left (ON)
- power up the device by plugging in USB power (if the battery is unattached, otherwise it'll power-on when you change the switch)

## software

https://www.raspberrypi.org/documentation/hardware/computemodule/cm-emmc-flashing.md

### preliminaries

first you'll need to get `rpiboot` (or comparable) installed for your os.

#### linux

```shell
sudo apt-get install libusb-1.0-0-dev
git clone --depth=1 https://github.com/raspberrypi/usbboot
cd usbboot
make
```

#### mac os

```shell
brew install libusb
git clone --depth=1 https://github.com/raspberrypi/usbboot
cd usbboot
make
```

### boot

once installed, run `rpiboot` (note the `sudo`)

```shell
sudo ./rpiboot
```

output should look something like:

```
Waiting for BCM2835/6/7
Sending bootcode.bin
Successful read 4 bytes
Waiting for BCM2835/6/7
Second stage boot server
File read: start.elf
Second stage boot server done
```

next, find the name of the norns disk.

#### linux

a disk will show up in /dev/sd? (normally something like `/dev/sdb`).

#### mac os

run `diskutil list` and note the name (norns is `3.9 GB` so that's a good clue).  the name will be something like `disk3`.

on mac os, it's important to unmount the disk before imaging (`diskutil unmountDisk /dev/disk<disk_name>`).  a successful command will look something like:

```shell
[~/norns] $ diskutil unmountDisk /dev/disk3
Unmount of all volumes on disk3 was successful
```

### copy the image

to copy image _to_ norns:

#### linux

```shell
sudo dd if=image.img of=/dev/sdb bs=4MiB status=progress conv=sparse
sync
```

#### mac os

```shell
sudo dd if=<my_img>.img of=/dev/r<disk_name> bs=4m conv=sparse
sync
```
(note the `r` prefix — this is important.  it specifies the raw disk and your transfer will be _far slower_ without it; for details, see this [thread](https://apple.stackexchange.com/questions/270514/macos-sierra-dd-to-usb-is-very-slow-and-cant-seem-to-use-dev-rdisk).)

if you want to see progress (it will take a while!), type `ctrl+t`  to send a `SIGINFO` command which will cause `dd` to dump status; for example, something like:

```shell
load: 2.24  cmd: dd 55210 uninterruptible 0.06u 7.48s
142+0 records in
141+0 records out
591396864 bytes transferred in 313.867907 secs (1884222 bytes/sec)
```

### copy the image (_from norns_)

reverse of/if to copy _from_ norns
