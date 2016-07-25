% function status = IllColPost(servAddr, db, user, pwd, col, event)
% Download event given a filename
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%
function status = IllColPost(servAddr, db, user, pwd, col, aEvent)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd};
queryString = http_paramsToString(params);
status = urlread2(['http://' servAddr ':8956/col?' queryString], 'POST', savejson('',aEvent), [], 'READ_TIMEOUT', 10000);