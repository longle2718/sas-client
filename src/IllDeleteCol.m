% function resp = IllDeleteCol(db, user, pwd, col, filename)
% Apply operation 'op' with field 'field' on document 'filename'. 
%
% 'field' is json, i.e. has the form {<name>:<value>}.
% 'op' includes (but not limited to, see the MongoDb field update operators
% for the complete list): inc, mul, max, min, set, unset.
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function resp = IllDeleteCol(db, user, pwd, col, filename)

params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd, 'filename', filename};
queryString = http_paramsToString(params);
resp = urlread2(['http://acoustic.ifp.illinois.edu:8956/write?' queryString], 'DELETE', [], [], 'READ_TIMEOUT', 15000);