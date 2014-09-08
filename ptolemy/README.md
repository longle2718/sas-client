Ptolemy II
============

## Usage

* 1. Run the matlab script SpeechEngine.m. This script will access Illiad service to obtain data in realtime and perfom voice activity detection (using the classic Sohn's VAD). The resuls is then reported to Ptolemy.
* 2. Open the ptolemy model SpeechEngineListener.xml and run it. This model simply listens for report from matlab SpeechEngine.m
