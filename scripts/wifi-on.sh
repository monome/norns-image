WIFI_INTERFACE=$(ip addr|grep 2: | awk '{print $2}'|sed -e s/:$//)

WPA_PS=$(ps aux | grep wpa_supplicant |grep -v grep | awk '{print $2}')
if [ -z $WPA_PS ]; then
    echo "starting wpa_supplicant..."
    sudo wpa_supplicant -B -i$WIFI_INTERFACE -c$HOME/wpa_supplicant.conf
fi


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
