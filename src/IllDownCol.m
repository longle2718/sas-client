% function event = IllDownCol(servAddr, db, user, pwd, col, filename)
% Download event given a filename
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function event = IllDownCol(servAddr, db, user, pwd, col, filename)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd};
queryString = http_paramsToString(params);
tmp = urlread2(['http://' servAddr ':8956/query?' queryString], 'POST', ['{"$and":[{"filename":"' filename '"}]}'], [], 'READ_TIMEOUT', 10000);
event = loadjson(tmp);
