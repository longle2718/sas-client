% function status = IllStatusGet(serviceAddr)
% get remote service status
%
% Long Le <longle1@illinois.edu>
% University of Illinois
%
function status = IllStatusGet(serviceAddr)
status = urlread2(['http://' serviceAddr '/'], 'GET', [], [], 'READ_TIMEOUT', 10000);
