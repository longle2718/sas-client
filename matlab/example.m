% Example scripts to use IlliadAccess
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%

clear all; close all

addpath(genpath('.'));
% Import cert into Matlab jvm truststore.
% Default alias is mykey
% Need write access to the truststore (cacerts)
% Only need to do this once.
%importcert('illiad.crt')

DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

% Query file list from the database, limited to max 24 files
q.limit = 24;
q.t1 = datenum(2014,10,9,0,0,0); q.t2 = datenum(2014,10,11,0,0,0); 
q.f1 = 0; q.f2 = 6000;
q.dur1 = 0.6; q.dur2 = 10.0;
%q.lnp2 = -6e2;
q.loc(1) = 40.1069855; q.loc(2) = -88.2244681; q.rad = 1;
events = IllQueryEvent(DB, USER, PWD, q);
% Download first available raw data
[data, y, header] = IllDownData(DB, USER, PWD, events{1}.filename);
% Play the sound
soundsc(y, double(header.sampleRate))
% Send to google voice api for speech recognition, quota 50 requests/day
%[tmp, resp] = gVoiceApi('YourGoogleKey', data);
% Or Nuance, quota 5000 requests/day!
%[tmp, resp] = nASRApi('YourNuanceID','YourNuanceKey', data);


% Download event descriptor
event = IllDownEvent(DB, USER, PWD, events{1}.filename);
% Display the first event
event{1}
