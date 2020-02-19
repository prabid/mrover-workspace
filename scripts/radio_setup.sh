#!/usr/bin/bash
#
#1. ssh into a server with username and password
#2. modify /tmp/system.cfg
#- radio.1.chanbw=1
#- radio.1.freq=2
#- radio.1.txpower=3

#add ability to change wireless mode from station to access point and vice versa

#add ability to change lock to ap when in station mode

USER=$1
PASSWORD=$2
RADIO=$3

if [ $# != 7 && $# != 8 ]
then
    echo "USAGE: ./radio_setup.tcl \[username\] \[password\] \[radio ip\] \[chanbw value\] \[channels value\] \[txpower value\] \[wireless mode\] \[access point radio ip \(optional\)\]"
    exit 1
fi

CHANBWVALUE=$4
CHANBW="radio.1.chanbw="+$CHANBWVALUE

CHANNELSVALUE=$5
CHANNELS="radio.1.freq="+$CHANNELSVALUE

TXPOWERSTRING="radio.1.txpower="
TXPOWERVALUE=$6
TXPOWER="radio.1.txpower="+$TXPOWERVALUE

MODEVALUE=$7

#TODO if modevalue is managed or master, leave it and don't cause errors

if [ $MODEVALUE == "station" ]
then
    MODEVALUE="managed"
    LOCKRADIO=$8
fi

if [ $MODEVALUE == "accesspoint" ]
then
    MODEVALUE="master"
fi

MODE="radio.1.mode="+$MODEVALUE

ssh $USER@$RADIO

sed -i -e "s/radio.1.chanbw=[0-9]*/[$CHANBW]/g" /tmp/system.cfg
sed -i -e "s/radio.1.freq=[0-9]*/[$CHANNELS]/g" /tmp/system.cfg
sed -i -e "s/radio.1.txpower=-*[0-9]*/[$TXPOWER]/g" /tmp/system.cfg
sed -i -e "s/radio.1.mode=.*/[$MODE]/g" /tmp/system.cfg

if [ $MODEVALUE == "managed" ]
then
    MACADDRESS="wireless.1.ap="

    if [ $LOCKRADIO == "10.9.0.1" ]
    then
        MACADDRESS+="68:72:51:80:26:A2"
    fi

    if [ $LOCKRADIO == "10.9.0.2" ]
    then
        MACADDRESS+="68:72:51:80:27:45"
    fi

    if [ $LOCKRADIO == "10.9.0.3" ]
    then
        MACADDRESS+="68:72:51:8A:29:27"
    fi
    
    if [ $LOCKRADIO == "10.9.0.5" ]
    then
        MACADDRESS+="68:72:51:8A:29:E8"
    fi

    sed -i -e "s/wireless.1.ap=.*/[$MACADDRESS]/g" /tmp/system.cfg
fi

save && reboot
exit