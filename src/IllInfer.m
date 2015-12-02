% function status = IllInfer(servAddr, db, user, pwd, col, event)
% Download event given a filename
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%
function status = IllInfer(servAddr, db, user, pwd, col, classname, filename)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd, 'classname', classname};
queryString = http_paramsToString(params);
aEvent.filename = filename;
status = urlread2(['http://' servAddr ':8956/infer?' queryString], 'POST', savejson('',aEvent), [], 'READ_TIMEOUT', 10000);