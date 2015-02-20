#!/bin/bash

# Accept .spx only
#speexenc "$1.wav" "$1.spx"
#curl "https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation?appId=NMDPTRIAL_long_061220140812074638&appKey=7e43d074f2f5fd9bb41f3c987dd2c514d8ffeb8f88a325b77ad80a5d1d951f9bd8ef10cae40d66982da231aa74f6bf4cf5aadc7e4d0135c8d93f25f7d44492ac&id=C4461956B60B" -H "Content-Type: audio/x-speex;rate=16000" -H "Accept-Language: ENUS" -H "Transfer-Encoding: chunked" -H "Accept: application/xml" -H "Accept-Topic: Dictation" -k --data-binary '@'"$1.spx"

# Accept .wav and .pcm
curl "https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation?appId=NMDPTRIAL_long_061220140812074638&appKey=7e43d074f2f5fd9bb41f3c987dd2c514d8ffeb8f88a325b77ad80a5d1d951f9bd8ef10cae40d66982da231aa74f6bf4cf5aadc7e4d0135c8d93f25f7d44492ac&id=C4461956B60B" -H "Content-Type: audio/x-wav;codec=pcm;bit=16;rate=16000" -H "Accept-Language: ENUS" -H "Content-Length: 34860" -H "Accept: application/xml" -H "Accept-Topic: Dictation" -k --data-binary @"$1" -v
