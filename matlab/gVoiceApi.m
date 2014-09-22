% [rawresp, resp] = gVoiceApi(key, data)
% Wrapper for google voice api
% IMPORTANT: you need to be in the chromium dev proj in order to use this 
% google servce!!!
%
% key is google dev key
% data is raw/char matrix of data
%
% rawresp is the raw string response
% resp is the response in json-converted/struct format
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function [rawresp, resp] = gVoiceApi(key, data)

params = {'output', 'json', 'lang', 'en-us', 'key', key};
queryString = http_paramsToString(params);
header = http_createHeader('Content-Type', 'audio/l16; rate=16000;');
rawresp = urlread2(['https://www.google.com/speech-api/v2/recognize?' queryString], 'POST', data, header, 'READ_TIMEOUT', 10000);
resp = loadjson(rawresp);
