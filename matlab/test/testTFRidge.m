% Test TF ridge computation
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%

clear all; close all;
%rootDir = 'C:/cygwin64/home/UyenBui/';
rootDir = '/home/blissbox/';
addpath([rootDir 'voicebox/'])
addpath([rootDir 'jsonlab/']);
addpath([rootDir 'V1_1_urlread2/']);
addpath([rootDir 'sas-client/matlab/src/']);

%%
servAddr = 'acoustic.ifp.illinois.edu:8080';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

%fNameExt = '8ea9fb9e-4a97-4689-a4dd-f5f481618f17.wav';
%fNameExt = '60568358-b0d0-4b98-a0a5-06b56b977bf8.wav';
fNameExt = 'aa77e55e-103a-4c31-a58b-83012ab49185.wav';

events = IllColGet(servAddr,DB, USER, PWD, EVENT, fNameExt); events{1}
data = IllGridGet(servAddr, DB, USER, PWD, DATA, fNameExt);
[y, header] = wavread_char(data);
fs = double(header.sampleRate);
sound(y,fs);
nBlk = events{1}.blkSize;
nInc = events{1}.incSize;
[S,ff,tt] = spectrogram(y,hanning(nBlk),nBlk-nInc,nBlk,fs);
S = abs(S);

fIdx = events{1}.TFRidgeFeat.FI/nBlk*fs;
tIdx = events{1}.TFRidgeFeat.TI*nInc/fs;

figure; hold on;
imagesc(tt,ff,S); axis tight; axis xy
plot(tIdx,fIdx,'*r')