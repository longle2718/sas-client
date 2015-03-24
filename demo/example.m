% Example scripts to use IlliadAccess
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%

clear all; close all

addpath(genpath('../matlab'));
% Import cert into Matlab jvm truststore.
% Default alias is mykey
% Need write access to the truststore (cacerts)
% Only need to do this once per Matlab copy.
%importcert('illiad.crt')

DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

% Query file list from the database, limited to max 24 files
q.limit = 50;
q.t1 = datenum(2015,3,22,0,0,0); q.t2 = datenum(2015,3,24,0,0,0); 
%q.f1 = 0; q.f2 = 6000;
%q.dur1 = 0.6; q.dur2 = 10.0;
%q.lnp2 = 6e4;
%q.loc(1) = 40.1069855; q.loc(2) = -88.2244681; q.rad = 1;
events = IllQueryCol(DB, USER, PWD, 'event', q);
% Download first available raw data
data = IllDownGrid(DB, USER, PWD, 'data', events{1}.filename);
[y, header] = wavread_char(data);
% Play the sound
soundsc(y, double(header.sampleRate))
% Send to google voice api for speech recognition, quota 50 requests/day
%[tmp, resp] = gVoiceApi('YourGoogleKey', data);
% Or Nuance, quota 5000 requests/day!
%[tmp, resp] = nASRApi('YourNuanceID','YourNuanceKey', data);


% Download event descriptor
event = IllDownCol(DB, USER, PWD, 'event', events{1}.filename);
% Display the first event
event{1}
