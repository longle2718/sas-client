% file = IllQueryRecord(db, user, pwd, q)
% Time query on the Illinois acoustic server.
%
% A query q is a structure of 
% .limit - cap on return items. A limit of 0 is equivalent to no limit.
% .t1 - starting time. Ex: datenum(2014,8,3,16,22,44)
% .t2 - ending time. Ex: datenum(2014,8,3,16,22,55)
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function file = IllQueryRecord(db, user, pwd, q)

% Adjust time zone from Central Time (US) to UTC
tZoneOffset = 5/24;

% Construct the query string
params = {'dbname', db, 'colname', 'record.files', 'user', user, 'passwd', pwd};
if (isfield(q, 'limit'))
    params(end+1:end+2) = {'limit', num2str(q.limit)};
end
queryString = http_paramsToString(params);

% Construct the query data to send
if isfield(q, 't1') && isfield(q,'t2')
    q.t1 = q.t1 + tZoneOffset;
    q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{uploadDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}, $lte:{$date:"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't1')
    q.t1 = q.t1 + tZoneOffset;
    timeDat = ['{uploadDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}}}'];
end

timeDat

tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', timeDat, [], 'READ_TIMEOUT', 10000);
file = loadjson(tmp);