% function [rawdat, data, header] = IllDownGrid(db, user, pwd, gridCol, filename)
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
function [rawdat, data, header] = IllDownGrid(db, user, pwd, gridCol, filename)

params = {'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
rawdat = urlread2(['https://acoustic.ifp.illinois.edu:8081/gridfs/' db '/' gridCol '?' queryString], 'GET', [], [], 'READ_TIMEOUT', 10000);
[data, header] = wavread_char(rawdat);