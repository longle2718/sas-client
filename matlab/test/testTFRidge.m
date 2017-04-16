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

fNameExt = 'c702e60a-351d-4742-a76b-18b2aafbbe70.wav';

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
tIdx = (events{1}.TFRidgeFeat.TI+1)*nInc/fs;

figure; hold on;
imagesc(tt,ff,S); axis tight; axis xy
plot(tIdx,fIdx,'*r')