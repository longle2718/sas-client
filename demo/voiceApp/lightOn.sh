#!/bin/bash

DEBUG=true
if [ $DEBUG = true ]; then
	BRIDGEIP=128.174.210.208
else
	BRIDGEIP=192.168.1.43
fi
USERNAME=760f6fe5759c473d26b123f29e86b
LIGHTID=2
DIR64=/cygdrive/c/cygwin64
DIR32=/cygdrive/c/cygwin
if [ -d $DIR64 ]; then
	DIR=$DIR64
elif [ -d $DIR32 ]; then
	DIR=$DIR32
else
	echo "Cygwin is not installed"
	exit -1
fi

$DIR/bin/curl --connect-timeout 3 -X PUT -H "Content-Type: application/json" -d '{"on":'"$1"'}' http://$BRIDGEIP/api/$USERNAME/lights/$LIGHTID/state

