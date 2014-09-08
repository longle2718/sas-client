% function event = IllDownEvent(db, user, pwd, filename)
% Download event given a filename
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function event = IllDownEvent(db, user, pwd, filename)

params = {'dbname', db, 'colname', 'event', 'user', user, 'passwd', pwd};
queryString = http_paramsToString(params);
tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', ['{filename:"' filename '"}'], [], 'READ_TIMEOUT', 10000);
event = loadjson(tmp);
