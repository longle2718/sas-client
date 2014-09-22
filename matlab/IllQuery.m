% file = IllQuery(db, user, pwd, q)
% Time query on the Illinois acoustic server.
%
% A query q is a structure of 
% .limit - cap on return items. A limit of 0 is equivalent to no limit.
% .t1 - starting time. Ex: datenum(2014,8,3,16,22,44)
% .t2 - ending time. Ex: datenum(2014,8,3,16,22,55)
% .f1 - lower frequency
% .f2 - upper frequency
% .loc - location array of lat and lng
% .rad - radius around the location
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function file = IllQuery(db, user, pwd, q)

% Adjust time zone from Central Time (US) to UTC
%tZoneOffset = 5/24;

% Construct the query string
params = {'dbname', db, 'colname', 'event', 'user', user, 'passwd', pwd};
if (isfield(q, 'limit'))
    params(end+1:end+2) = {'limit', num2str(q.limit)};
end
queryString = http_paramsToString(params);

% Construct the query data to send
postDat = '';

if isfield(q, 't1') && isfield(q,'t2')
    %q.t1 = q.t1 + tZoneOffset;
    %q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{recordDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}, $lte:{$date:"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't1')
    %q.t1 = q.t1 + tZoneOffset;
    timeDat = ['{recordDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}}}'];
end

if isfield(q, 'f1') && isfield(q, 'f2')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}},{maxFreq:{$lte:' num2str(q.f2) '}}'];
elseif isfield(q, 'f1')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}}'];
else
    freqDat = '';
end

if isfield(q, 'loc') && isfield(q, 'rad')
    % loc(1) - lat, loc(2) - lng
    locDat = [',{location:{$geoWithin:{$centerSphere:[[' num2str(q.loc(2)) ',' num2str(q.loc(1)) '], ' num2str(q.rad) ']}}}'];
else
    locDat = '';
end

if isfield(q, 'kw')
    kwDat = [',{transcript:' q.kw '}'];
else
    kwDat = '';
end

postDat = ['{$and:[' timeDat freqDat locDat kwDat ']}'];

tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', postDat, [], 'READ_TIMEOUT', 10000);
file = loadjson(tmp);