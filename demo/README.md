Demo 1
============
Voice activity detection in MatLab with Ptolemy II interface

## Usage

* 1. Run the matlab script SpeechEngine.m. This script will access Illiad service (require certificate imported) to obtain data in realtime and perfom voice activity detection (using the classic Sohn's VAD). The resuls is then reported to Ptolemy.
* 2. Open the ptolemy model SpeechEngineListener.xml and run it. This model simply listens for reports from matlab SpeechEngine.m

Demo 2
============
Keyword recognition using external services, i.e. Google Voice or Nuance Automatic Speech Recognization (ASR) API, in Matlab

## Usage

* Ensure that Illiad accessor code is executable, i.e. certificate is imported. Then simply run the voiceApp.m.
