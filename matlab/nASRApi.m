% [rawresp, resp] = nASRApi(id, key, data)
% Wrapper for nuance automatic speech recognition (ASR) API
%
% id is appId
% key is appKey
% data is raw/char matrix of data
%
% rawresp is the raw string response
% resp is the response in cell
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function [rawresp, resp] = nASRApi(id, key, data)

params = {'appId', id, 'appKey', key, 'id', 'C4461956B60B'};
queryString = http_paramsToString(params);
header(1) = http_createHeader('Content-Type', 'audio/x-wav;codec=pcm;bit=16;rate=16000');
header(2) = http_createHeader('Accept-Language', 'ENUS');
header(3) = http_createHeader('Content-Length', num2str(length(data)-44)); % Do not send header, according to the API.
header(4) = http_createHeader('Accept', 'application/xml');
header(5) = http_createHeader('Accept-Topic', 'Dictation');
rawresp = urlread2(['https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation?' queryString], 'POST', data(45:end), header, 'READ_TIMEOUT', 10000);
resp = textscan(rawresp, '%s', 'delimiter', sprintf('\n')); % expecting cell of size 1
if (strcmp(resp{1}{1}, '<html>'))
    resp = 'Nuance error';
end
