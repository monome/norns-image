#init gpio

echo "28" > /sys/class/gpio/export
echo "29" > /sys/class/gpio/export
echo "31" > /sys/class/gpio/export
echo "32" > /sys/class/gpio/export
echo "33" > /sys/class/gpio/export
echo "35" > /sys/class/gpio/export
echo "36" > /sys/class/gpio/export
echo "37" > /sys/class/gpio/export
echo "39" > /sys/class/gpio/export

# turn analog gain stages to unity
# note this gain stage is only applicable to round 1 prototypes
# this will throw an error on others.
# Channel 0 0000 0000
sudo i2cset -y 1 0x28 0x00
# Channel 1 0100 0000
sudo i2cset -y 1 0x28 0x40

# input gain stage. the default is mute so we skip this. we let matron turn it on.
# but the values below are sane defaults otherwise (unity gain)
#sudo i2cset -y 1 0x29 16
#sudo i2cset -y 1 0x29 80

# unmute soundcard output
amixer set Master 100% on

# enable headphone driver
sudo i2cset -y 1 0x60 1 192    # enable HP outputs
sudo i2cset -y 1 0x60 2 32     # unmute, set vol to -10db
#sudo i2cset -y 1 0x60 2 52     # unmute, set vol to 0.1db

echo "in" > /sys/class/gpio/gpio28/direction
echo "both" > /sys/class/gpio/gpio28/edge

echo "in" > /sys/class/gpio/gpio29/direction
echo "both" > /sys/class/gpio/gpio29/edge

echo "in" > /sys/class/gpio/gpio31/direction
echo "both" > /sys/class/gpio/gpio31/edge

echo "in" > /sys/class/gpio/gpio32/direction
echo "both" > /sys/class/gpio/gpio32/edge

echo "in" > /sys/class/gpio/gpio33/direction
echo "both" > /sys/class/gpio/gpio33/edge

echo "in" > /sys/class/gpio/gpio35/direction
echo "both" > /sys/class/gpio/gpio35/edge

echo "in" > /sys/class/gpio/gpio36/direction
echo "both" > /sys/class/gpio/gpio36/edge

echo "in" > /sys/class/gpio/gpio37/direction
echo "both" > /sys/class/gpio/gpio37/edge

echo "in" > /sys/class/gpio/gpio39/direction
echo "both" > /sys/class/gpio/gpio39/edge

# start norns
su pi -c "cd /home/pi/norns; ./start.sh;"

# start maiden
su pi -c "cd /home/pi/maiden; ./start.sh;"

# clean up stale wifi status from shutdown
echo stopped > $HOME/status.wifi
