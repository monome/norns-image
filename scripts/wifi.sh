function wpa_boot {
    WPA_PS=$(ps aux | grep wpa_supplicant |grep -v grep | awk '{print $2}')
    if [ -z $WPA_PS ]; then
	echo "starting wpa_supplicant..."
	WPA_FILE=$HOME/wpa_supplicant.conf
	echo ctrl_interface=/run/wpa_supplicant > $WPA_FILE
	echo update_config=1 >> $WPA_FILE
	WIFI_INTERFACE=$(ip addr|grep 2: | awk '{print $2}'|sed -e s/:$//)
	sudo wpa_supplicant -B -i$WIFI_INTERFACE -c$WPA_FILE
    fi
}

function all_off {
    sudo ifdown wlan0
    sudo service hostapd stop
    sudo service dnsmasq stop
    sudo killall wpa_supplicant
    sudo killall dhcpcd
}

if [ $1 = "on" ]; then
    all_off;
    wpa_boot;
    SSID=$(cat $HOME/ssid.wifi);
    PSK=$(cat $HOME/psk.wifi);
    sudo killall dhcpcd
    # sudo wpa_cli list_networks
    sudo wpa_cli disable_network 0

    sudo wpa_cli remove_network 0
    sudo wpa_cli remove_network 1
    sudo wpa_cli remove_network 2
    sudo wpa_cli remove_network 3
    sudo wpa_cli remove_network 4

    sudo wpa_cli add_network

    if [ -n "$PSK" ]; then
        sudo wpa_cli set_network 0 psk "\"$PSK\""
    else
        sudo wpa_cli set_network 0 key_mgmt NONE
    fi

    echo sudo wpa_cli set_network 0 ssid "\"$SSID\""
    sudo wpa_cli set_network 0 ssid "\"$SSID\""

    sudo wpa_cli enable_network 0

    sudo wpa_cli list_networks
    sleep 5
    sudo dhcpcd
    ping monome.org
elif [ $1 = "scan" ]; then
    wpa_boot;
    sudo wpa_cli scan > /dev/null;
    sleep 5;
    sudo wpa_cli scan_results \
	| sed -e s/.\*\\\]// -e s/\[\ \\t\]\*// \
	| awk '(NR>2) {print};'
elif [ $1 = "select" ]; then
    if [ -n "$1" ]; then
	echo $2 > $HOME/ssid.wifi;
	echo $3 > $HOME/psk.wifi;
    else
	echo "usage: ./wifi.sh select \"SSID\" \"PSK\""
    fi
elif [ $1 = "hotspot" ]; then
    all_off
    sudo ifup wlan0
    sudo service hostapd start
    sudo service dnsmasq start
elif [ $1 = "off" ]; then
    all_off
fi    
