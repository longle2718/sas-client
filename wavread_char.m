function [data, header] = wavread_char(dat)
% [data, header] = wavread_char(dat)
% Convert char matrix 'dat' to matlab double, just like wavread, but
% without the file interface.
%
% data is a double matrix 
% header is a struct
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
if (~strcmp(dat(1:4), 'RIFF'))
    error('Not in Wave format')
end

% header chunk
head = dat(1:44); 
header.numChannels = typecast(uint8(head(23:24)), 'uint16');
header.sampleRate = typecast(uint8(head(25:28)), 'uint32');
header.byteRate = typecast(uint8(head(29:32)), 'uint32');
header.blockAlign = typecast(uint8(head(33:34)), 'uint16');
header.bitsPerSample = typecast(uint8(head(35:36)), 'uint16');

% data chunk
dat = dat(45:end);
int16dat = typecast(uint8(dat), 'int16');
data = double(int16dat)/abs(double(intmin('int16')));