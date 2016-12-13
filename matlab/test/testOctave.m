% Test octave band computation
%
% Duc Phan <ducphan2@illinois.edu>
% University of Illinois
%

clear all; close all;
%rootDir = 'C:/cygwin64/home/UyenBui/';
rootDir = '/home/blissbox/';
addpath([rootDir 'voicebox/'])
addpath([rootDir 'jsonlab/']);
addpath([rootDir 'V1_1_urlread2/']);
addpath([rootDir 'sas-client/matlab/src/']);

%% get service data
servAddr = 'acoustic.ifp.illinois.edu:8080';
DB = 'publicDb';
USER = 'nan';
PWD = 'publicPwd';
DATA = 'data';
EVENT = 'event';

frameSize = 512;
fNameExt = 'aa77e55e-103a-4c31-a58b-83012ab49185.wav';

events = IllColGet(servAddr,DB, USER, PWD, EVENT, fNameExt);
data = IllGridGet(servAddr, DB, USER, PWD, DATA, fNameExt);
[y, header] = wavread_char(data);
fs = double(header.sampleRate);

%% compare with ground truth octave band

androidResult = events{1}.octaveFeat';
[L K] =size(androidResult);
N= frameSize;
windows = hann(N);
noverlap =N/2;
nfft =N;
nAverageFrame =62;
n=log2(N)-1; % 

% set up octave 
octave_group=zeros(n,N/2+1);
firstInd =2;
for i=1:n
    numOfBinsInGroup = 2^(i-1);
    lastInd = firstInd+numOfBinsInGroup-1;
    octave_group(i,firstInd:lastInd)=ones(1,numOfBinsInGroup);
    firstInd =lastInd+1;
end

S =spectrogram([zeros(1,frameSize/2) y],windows,noverlap,nfft); % must zero pad
power=abs(S).^2;
temp = octave_group*power;
expectOctaveFeat = zeros(L,K);
for i=1:K
  expectOctaveFeat(:,i) =sum(temp(:,1+(i-1)*nAverageFrame:i*nAverageFrame),2)/nAverageFrame;
end

% ignore 1 octave frame
figure;
subplot(211); imagesc(androidResult);
subplot(212); imagesc(expectOctaveFeat);
suptitle(sprintf(' norm diff is %.3f',norm( expectOctaveFeat-androidResult )));
