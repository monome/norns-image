status=$(cat /sys/class/power_supply/bq27441-0/status);
capacity=$(cat /sys/class/power_supply/bq27441-0/capacity);
echo Battery $status $capacity%
