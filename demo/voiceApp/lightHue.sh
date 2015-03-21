#!/bin/bash

DEBUG=true
if [ $DEBUG = true ]; then
	BRIDGEIP=128.174.226.140
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

HUE=`$DIR/bin/curl --connect-timeout 3 http://$BRIDGEIP/api/$USERNAME/lights/$LIGHTID|$DIR/bin/jq '.state.hue'`
HUE=`echo $HUE|$DIR/bin/sed 's/\\r//g'`
$DIR/bin/curl --connect-timeout 15 -X PUT -H "Content-Type: application/json" -d '{"hue":'"$[$1+$HUE]"'}' http://$BRIDGEIP/api/$USERNAME/lights/$LIGHTID/state

