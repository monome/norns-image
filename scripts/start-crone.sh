#!/bin/bash 
PATH=$PATH:/usr/local/bin:/usr/bin
export DISPLAY=:0.0
#/home/pi/norns/ipc-wrapper/ipc-wrapper /home/pi/norns/matron/matron ipc:///tmp/matron_in.ipc ipc:///tmp/matron_out.ipc > /home/pi/matron.log &

# ipc wrapper requires full path 
SCLANG=$(which sclang)
/home/pi/norns/ipc-wrapper/ipc-wrapper $SCLANG ipc:///tmp/crone_in.ipc ipc:///tmp/crone_out.ipc > /home/pi/crone.log &
