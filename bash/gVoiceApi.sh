#!/bin/bash

# Convert to .flac before sending to google
#sox "$1.wav" "$1.flac" rate 16000
#curl -X POST --data-binary '@'"$1.flac" -H 'Content-Type: audio/x-flac; rate=16000;' 'https://www.google.com/speech-api/v2/recognize?output=json&lang=en-us&key=AIzaSyD5NvcrQ54Rbzdxpo3FtJsAyvUjy6O3cn4'

# Accept .wav
curl -X POST --data-binary '@'"$1" -H 'Content-Type: audio/l16; rate=16000;' 'https://www.google.com/speech-api/v2/recognize?output=json&lang=en-us&key=AIzaSyD5NvcrQ54Rbzdxpo3FtJsAyvUjy6O3cn4' -v
