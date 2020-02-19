#!/usr/bin/bash

# A script for getting
# Intended to be called by python program in /vagrant/base_station/radio_update
# To execute the python program, run:
    # jarvis build base_station/radio_update
    # jarvis exec base_station_radio_update

# Command line arguments

USER=$1
PASSWORD=$2
RADIO=$3

# Constants

# Radio connection timeout
timeout=20
# Directory for storing files
TMPDIR="/tmp"
# Name of temp data file
DATA_FILE="tmp_radio_data.json"

# Error if invalid argument count
if [ $# != 3 && $# != 4 ]
then
    echo "USAGE: ./signal_strength.tcl \[username\] \[password\] \[station radio ip\] (optional: temp-file directory)"
    exit 1
fi

# If temp-file directory argument is specified
if [ $# == 4 ]
then
    # If specified path is actually a directory, set TMPDIR to the path
    if [ ! -d $4 ]
    then
        TMPDIR=$4
    # If specified path isn't actually a directory, error and quit
    else
        echo "Specified temp-file directory is not a directory"
        exit 1
    fi
fi

# Create data file if doesn't exist
touch $TMPDIR/$DATA_FILE

# Initiate secure copy of radio data file to base station
scp $USER@$RADIO:/tmp/stats/wstalist $TMPDIR/$DATA_FILE

# TODO: If not connected

# Get the first occurence of "signal" in temp data file
cat $TMPDIR/$DATA_FILE | grep -m1 signal
