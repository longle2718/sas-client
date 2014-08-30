% Example scripts to use IlliadAccess
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%

clear all; close all

addpath(genpath('.'));
% Import cert into Matlab jvm truststore.
% Need write access to the truststore (cacerts)
% Only need to do this once.
%importcert('mongoser.crt')

% Query file list from the database, limited to max 24 files
% IllTimeQuery assumes Central Time.
file = IllTimeQuery('YourDB', 'YourID', 'YourPwd', datenum(2014,8,19,12,20,0), '24');
% Download first available raw data
[data, y, header] = IllDownData('YourDB', 'YourID', 'YourPwd', file{1}.filename);
% Play the sound
soundsc(y, double(header.sampleRate))
% Send to google voice api for speech recognition, quota 50 requests/day
%[tmp, resp] = gVoiceApi('YourGoogleKey', data);
% Or Nuance, quota 5000 requests/day!
%[tmp, resp] = nASRApi('YourNuanceID','YourNuanceKey', data);


% Download event descriptor
event = IllDownEvent('YourDB', 'YourID', 'YourPwd', file{1}.filename);
% Display the first event
event{1}
