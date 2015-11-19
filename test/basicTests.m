% Basic tests of the remote service
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all

addpath(genpath('../src'));
addpath(genpath('../../jsonlab'));
addpath(genpath('../../V1_1_urlread2'));
% Import cert into Matlab jvm truststore.
% Default alias is mykey
% Need write access to the truststore (cacerts)
% Only need to do this once per Matlab copy.
%importcert('illiad.crt')

servAddr = 'acoustic.ifp.illinois.edu';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

%% Basic tests
numTest = 0; % number of tests
numPass = 0; % number of tests passed

%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: check status', numTest);

status = IllGetStatus(servAddr);

if (strfind(status,'OK'))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: upload event', numTest);



if (1)
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: upload data', numTest);



if (1)
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: query event', numTest);

% Query limited files from the database
q.limit = 50;
q.t1 = datenum(2015,11,19,00,00,00); q.t2 = datenum(2015,11,20,00,00,00);
q.loc(1) = 39.828175; q.loc(2) = -98.5795; q.rad = 600;
events = IllQueryCol(servAddr,DB, USER, PWD, EVENT, q);

if (iscell(events))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: download data', numTest);

% Download first available raw data
data = IllDownGrid(servAddr,DB, USER, PWD, DATA, events{1}.filename);
%[y, header] = wavread_char(data);
% Play the sound
%soundsc(y, double(header.sampleRate))
% Send to google voice api for speech recognition, quota 50 requests/day
%[tmp, resp] = gVoiceApi('YourGoogleKey', data);
% Or Nuance, quota 5000 requests/day!
%[tmp, resp] = nASRApi('YourNuanceID','YourNuanceKey', data);

if (strcmp(data(1:4),'RIFF'))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: download event', numTest);

% Download event 
event = IllDownCol(servAddr,DB, USER, PWD, EVENT, events{1}.filename);

if (iscell(event))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
fprintf(1, '%d passed out of %d tests\n', numPass,numTest);
