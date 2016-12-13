% Basic tests of the remote service
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all

rootDir = 'C:/Users/Long/Projects/';

addpath([rootDir 'sas-clientLib/src/']);
addpath([rootDir 'jsonlab']);
addpath([rootDir 'V1_1_urlread2']);
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

status = IllStatusGet(servAddr);

if (strfind(status,'OK'))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
%{
numTest = numTest + 1;
fprintf(1, 'Test %d: check models', numTest);

models = IllModelGet(servAddr);

if iscell(models)
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%}
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: send event', numTest);

aEvent.filename = 'testPoint';
aEvent.key = PWD;
aEvent.a = 1;
status = IllColPost(servAddr, DB, USER, PWD, EVENT, aEvent);

if strfind(status,'inserted')
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: query event', numTest);

% Query limited files from the database
q.filename = 'testPoint';
% DO NOT test post /register, will create leaked memory in the remote
% server
events = IllQuery(servAddr,DB, USER, PWD, EVENT, q);

if iscell(events)
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: download event', numTest);

% Download event 
events = IllColGet(servAddr,DB, USER, PWD, EVENT, events{1}.filename);

if iscell(events)
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: update event', numTest);

resp = IllColPut(servAddr, DB, USER, PWD, EVENT, 'testPoint', 'inc', '{"a":1}');
jsonResp = loadjson(resp);

if isfield(jsonResp,'ok')
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: send data', numTest);

fid = fopen('./hello.wav','r');
data = fread(fid,'*char');
fclose(fid);
resp = IllGridPost(servAddr, DB, USER, PWD, DATA, 'testPoint', data);

if strfind(resp,'inserted')
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: download data', numTest);

% Download first available raw data
data = IllGridGet(servAddr, DB, USER, PWD, DATA, 'testPoint');
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
%{
numTest = numTest + 1;
fprintf(1, 'Test %d: infer', numTest);

resp = IllInfer(servAddr, DB, USER, PWD, EVENT, 'speech', 'testPoint');
jsonResp = loadjson(resp);

if isstruct(jsonResp{1})
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%}
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: delete event', numTest);

resp = IllColDelete(servAddr, DB, USER, PWD, EVENT, 'testPoint');
jsonResp = loadjson(resp);

if isfield(jsonResp,'ok') && jsonResp.ok == 1
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
numTest = numTest + 1;
fprintf(1, 'Test %d: delete data', numTest);

resp = IllGridDelete(servAddr, DB, USER, PWD, DATA, 'testPoint');

if (strfind(resp,'file deleted'))
    fprintf(1, '... PASSED\n');
    numPass = numPass + 1;
else
    fprintf(1, '... FAILED\n');
end
%====================================================
fprintf(1, '%d passed out of %d tests\n', numPass,numTest);
