% function [rawdat, data, header] = IllDownRecord(db, user, pwd, filename)
% Download data given a filename
%
% rawdat is a char matrix
% data is a double matrix
% header is a struct
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function [rawdat, data, header] = IllDownRecord(db, user, pwd, filename)

params = {'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
rawdat = urlread2(['https://acoustic.ifp.uiuc.edu:8081/gridfs/' db '/record?' queryString], 'GET', [], [], 'READ_TIMEOUT', 10000);
[data, header] = wavread_char(rawdat);