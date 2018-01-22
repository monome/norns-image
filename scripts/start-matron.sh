#!/bin/bash
case "$(pidof matron | wc -w)" in
0)
HOME=/home/pi
$HOME/norns/ipc-wrapper/ipc-wrapper $HOME/norns/matron/matron ipc:///tmp/matron_in.ipc ipc:///tmp/matron_out.ipc > /home/pi/matron.log &
;;
1) echo "matron already running"
;;
esac
