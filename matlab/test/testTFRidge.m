% Test TF ridge computation
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all;
rootDir = 'C:/cygwin64/home/UyenBui/';
addpath([rootDir 'voicebox/'])
addpath([rootDir 'jsonlab/']);
addpath([rootDir 'V1_1_urlread2/']);
addpath([rootDir 'sas-clientLib/matlab/src/']);

%%
servAddr = 'acoustic.ifp.illinois.edu:8080';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

%fNameExt = '20160315211646212.wav';
%fNameExt = '20160315212644770.wav';
%fNameExt = '20160315213404470.wav';
%fNameExt = '20160315213639396.wav';
%fNameExt = '20160315221001584.wav';
fNameExt = '20160315221200844.wav';

events = IllColGet(servAddr,DB, USER, PWD, EVENT, fNameExt);
data = IllGridGet(servAddr, DB, USER, PWD, DATA, fNameExt);
[y, header] = wavread_char(data);
fs = double(header.sampleRate);
sound(y,fs);
nBlk = events{1}.fftSize;
nInc = events{1}.fftSize/2;
[S,tt,ff] = mSpectrogram(y,fs,nBlk,nInc);

tStr = fieldnames(events{1}.TFRidgeFeat);
tIdx = zeros(1,numel(tStr));
fIdx = cell(1,numel(tStr));
for k = 1:numel(tStr)
    tIdx(k) = sscanf(tStr{k},'t%d');
    fIdx{k} = events{1}.TFRidgeFeat.(tStr{k});
end

% size = 1st full block + incremental blocks
obs = cell(1,fix((0.8+events{1}.maxDur)*fs/nInc)-1); % assume lag of sensor is 2 x 0.4 s
tBaseIdx = fix(0.4*fs/nInc);
btLenIdx = fix(0.064*fs/nInc); % assume btLen of sensor is 0.064 s
for k = 1:numel(tIdx)
    obs{tBaseIdx+tIdx(k)-btLenIdx} = fIdx{k};
end

figure; hold on;
imagesc(S); axis tight; axis xy
for k = 1:numel(obs)
    if numel(obs{k}) ~= 0
        plot(k,obs{k},'*r')
    end
end