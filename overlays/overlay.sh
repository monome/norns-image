sudo dtc -I dts -O dtb -o /boot/dt-blob.bin dt-blob.dts
sudo dtc -I dts -o /boot/overlays/bq27441.dtbo bq27441.dts
sudo dtc -I dts -o /boot/overlays/monome.dtbo monome-overlay.dts
sudo dtc -I dts -o /boot/overlays/ssd1322-spi.dtbo ssd1322-spi-overlay.dts
