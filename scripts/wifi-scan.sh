
WIFI_INTERFACE=$(ip addr|grep 2: | awk '{print $2}'|sed -e s/:$//)

WPA_PS=$(ps aux | grep wpa_supplicant |grep -v grep | awk '{print $2}')
if [ -z $WPA_PS ]; then
    echo "starting wpa_supplicant..."
    WPA_FILE=$HOME/wpa_supplicant.conf
    echo ctrl_interface=/run/wpa_supplicant > $WPA_FILE
    echo update_config=1 >> $WPA_FILE
    sudo wpa_supplicant -B -i$WIFI_INTERFACE -c$WPA_FILE
fi

sudo wpa_cli scan > /dev/null;
sleep 5;
sudo wpa_cli scan_results | sed -e s/.\*\\\]// -e s/\[\ \\t\]\*// | awk '(NR>2) {print};'
