#!/bin/bash
#
#1. ssh into a server with username and password
#2. modify /tmp/system.cfg
#- radio.1.chanbw=1
#- radio.1.freq=2
#- radio.1.txpower=3

#add ability to change wireless mode from station to access point and vice versa

#add ability to change lock to ap when in station mode
set -x

if [[ $# -ne 6 && $# -ne 7 ]]; then
    echo "USAGE: ./radio_setup.sh \[username\] \[radio ip\] \[chanbw value\] \[channels value\] \[txpower value\] \[wireless mode\] \[access point radio ip \(optional\)\]"
    exit 1
fi

USER=$1
RADIO=$2

CHANBWDEC="radio.1.chanbw="
CHANBW=$CHANBWDEC+$3

CHANNELSDEC="radio.1.freq="
CHANNELS=$CHANNELSDEC+$4

TXPOWERDEC="radio.1.txpower"
TXPOWER=$TXPOWERDEC+$5

MODEDEC="radio.1.mode="
MODEVALUE=$6

#TODO if modevalue is managed or master, leave it and don't cause errors

if [ $MODEVALUE == "station" ]; then
    MODEVALUE="managed"
    LOCKRADIO=$7
elif [ $MODEVALUE == "accesspoint" ]; then
    MODEVALUE="master"
fi

MODE=$MODEDEC+$MODEVALUE

ssh $USER@$RADIO

sed -i -e "s/$CHANBWDEC[0-9]*/[$CHANBW]/g" /tmp/system.cfg
sed -i -e "s/$CHANNELSDEC[0-9]*/[$CHANNELS]/g" /tmp/system.cfg
sed -i -e "s/$TXPOWERDEC-*[0-9]*/[$TXPOWER]/g" /tmp/system.cfg
sed -i -e "s/$MODEDEC.*/[$MODE]/g" /tmp/system.cfg

if [ $MODEVALUE == "managed" ]; then
    MACADDRESS="wireless.1.ap="

    if [ $LOCKRADIO == "10.9.0.1" ]; then
        MACADDRESS+="68:72:51:80:26:A2"
    elif [ $LOCKRADIO == "10.9.0.2" ]; then
        MACADDRESS+="68:72:51:80:27:45"
    elif [ $LOCKRADIO == "10.9.0.3" ]; then
        MACADDRESS+="68:72:51:8A:29:27"
    elif [ $LOCKRADIO == "10.9.0.5" ]; then
        MACADDRESS+="68:72:51:8A:29:E8"
    fi

    sed -i -e "s/wireless.1.ap=.*/[$MACADDRESS]/g" /tmp/system.cfg
fi

save && reboot
exit