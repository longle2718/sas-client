% file = IllQueryEvent(db, user, pwd, q)
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
% .dur1 - lower duration
% .dur2 - upper duration
% .lnp1 - lower log noise prob
% .lnp2 - upper log noise prob
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function file = IllQueryEvent(db, user, pwd, q)

% Adjust time zone from Central Time (US) to UTC
tZoneOffset = 5/24;

% Construct the query string
params = {'dbname', db, 'colname', 'event', 'user', user, 'passwd', pwd};
if (isfield(q, 'limit'))
    params(end+1:end+2) = {'limit', num2str(q.limit)};
end
queryString = http_paramsToString(params);

% Construct the query data to send
if isfield(q, 't1') && isfield(q,'t2')
    q.t1 = q.t1 + tZoneOffset;
    q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{recordDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}, $lte:{$date:"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't1')
    q.t1 = q.t1 + tZoneOffset;
    timeDat = ['{recordDate:{$gte:{$date:"' datestr8601(q.t1, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't2')
    q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{recordDate:{$lte:{$date:"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
end

if isfield(q, 'f1') && isfield(q, 'f2')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}},{maxFreq:{$lte:' num2str(q.f2) '}}'];
elseif isfield(q, 'f1')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}}'];
elseif isfield(q, 'f2')
    freqDat = [',{maxFreq:{$lte:' num2str(q.f2) '}}'];
else
    freqDat = '';
end

if isfield(q, 'loc') && isfield(q, 'rad')
    % loc(1) - lat, loc(2) - lng
    locDat = [',{location:{$geoWithin:{$centerSphere:[[' num2str(q.loc(2)) ',' num2str(q.loc(1)) '], ' num2str(q.rad) ']}}}'];
else
    locDat = '';
end

if isfield(q, 'dur1') && isfield(q, 'dur2')
    durDat = [',{duration:{$gte:' num2str(q.dur1) '}},{maxFreq:{$lte:' num2str(q.dur2) '}}'];
elseif isfield(q, 'f1')
    durDat = [',{duration:{$gte:' num2str(q.dur1) '}}'];
elseif isfield(q, 'f2')
    durDat = [',{duration:{$lte:' num2str(q.dur2) '}}'];    
else
    durDat = '';
end

if isfield(q, 'lnp1') && isfield(q, 'lnp2')
    lnpDat = [',{logNoiseProb:{$gte:' num2str(q.dur1) '}},{maxFreq:{$lte:' num2str(q.dur2) '}}'];
elseif isfield(q, 'f1')
    lnpDat = [',{duration:{$gte:' num2str(q.dur1) '}}'];
elseif isfield(q, 'f2')
    lnpDat = [',{duration:{$lte:' num2str(q.dur2) '}}'];    
else
    lnpDat = '';
end

if isfield(q, 'kw')
    kwDat = [',{$text: {$search:"' q.kw '"}}'];
else
    kwDat = '';
end

postDat = ['{$and:[' timeDat freqDat locDat durDat lnpDat kwDat ']}'];

tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', postDat, [], 'READ_TIMEOUT', 10000);
file = loadjson(tmp);