% function resp = IllGridDelete(servAddr, db, user, pwd, col, filename)
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function resp = IllGridDelete(servAddr, db, user, pwd, col, filename)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
resp = urlread2(['http://' servAddr '/gridfs?' queryString], 'DELETE', [], [], 'READ_TIMEOUT', 15000);
