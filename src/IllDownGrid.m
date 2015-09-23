% function rawdat = IllDownGrid(db, user, pwd, gridCol, filename)
% Download data given a filename
%
% rawdat is a char matrix
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function rawdat = IllDownGrid(db, user, pwd, gridCol, filename)

params = {'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
rawdat = urlread2(['http://acoustic.ifp.illinois.edu:8956/gridfs/' db '/' gridCol '?' queryString], 'GET', [], [], 'READ_TIMEOUT', 10000);