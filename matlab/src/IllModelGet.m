% function models = IllModelGet(serviceAddr)
% get remote service support models
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%
function models = IllModelGet(serviceAddr)
tmp = urlread2(['http://' serviceAddr '/model'], 'GET', [], [], 'READ_TIMEOUT', 10000);
models = loadjson(tmp);
