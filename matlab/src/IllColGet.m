% function event = IllColGet(servAddr, db, user, pwd, col, filename)
% Download event given a filename
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function event = IllColGet(servAddr, db, user, pwd, col, filename)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
tmp = urlread2(['http://' servAddr ':8956/col?' queryString], 'GET', [], [], 'READ_TIMEOUT', 10000);
event = loadjson(tmp);
