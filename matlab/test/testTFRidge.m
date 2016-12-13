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

fNameExt = 'c49cd4db-1c96-433f-b367-8a7fd8616dea.wav';
%fNameExt = 'fb3d6943-c07c-4857-808b-ab236f5a5138.wav';
%fNameExt = 'b0d6c83b-3117-473e-b81d-3209ecd17458.wav';
%fNameExt = '03034b5f-0279-4eea-8f19-de679b97d92c.wav';
%fNameExt = '644904f9-f1b7-48b1-8fc1-5543b0bff98b.wav';

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