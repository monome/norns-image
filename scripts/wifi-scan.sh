
WIFI_INTERFACE=$(ip addr|grep 2: | awk '{print $2}'|sed -e s/:$//)

WPA_PS=$(ps aux | grep wpa_supplicant |grep -v grep | awk '{print $2}')
if [ -z $WPA_PS ]; then
    echo "starting wpa_supplicant..."
    sudo wpa_supplicant -B -i$WIFI_INTERFACE -c$HOME/wpa_supplicant.conf
fi

sudo wpa_cli scan > /dev/null;
sleep 5;
sudo wpa_cli scan_results | sed -e s/.\*\\\]// -e s/\[\ \\t\]\*// | awk '(NR>2) {print};'
