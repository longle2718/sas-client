% file = IllQuery(servAddr, db, user, pwd, col, q)
% Time query on the Illinois acoustic server.
%
% A query q is a structure of 
% .limit - cap on return items. A limit of 0 is equivalent to no limit.
% .t1 - starting time. Ex: datenum(2014,8,3,16,22,44)
% .t2 - ending time. Ex: datenum(2014,8,3,16,22,55)
% .loc - location array of lat and lng: loc(1) - lat, loc(2) - lng
% .rad - radius around the location, in miles
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function file = IllQuery(servAddr, db, user, pwd, col, q)

% Adjust time zone from Central Time (US) to UTC
%tZoneOffset = 5/24;
earthRad = 3959; % miles

% Construct the query string
params = {'dbname', db, 'colname', col, 'user', user, 'passwd', pwd};
if (isfield(q, 'limit'))
    params(end+1:end+2) = {'limit', num2str(q.limit)};
end
queryString = http_paramsToString(params);

% Construct the query data to send
if isfield(q, 't1') && isfield(q,'t2')
    %q.t1 = q.t1 + tZoneOffset;
    %q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{"recordDate":{"$gte":{"$date":"' datestr8601(q.t1, '*ymdHMS3') 'Z"}, "$lte":{"$date":"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't1')
    %q.t1 = q.t1 + tZoneOffset;
    timeDat = ['{"recordDate":{"$gte":{"$date":"' datestr8601(q.t1, '*ymdHMS3') 'Z"}}}'];
elseif isfield(q, 't2')
    %q.t2 = q.t2 + tZoneOffset;
    timeDat = ['{"recordDate":{"$lte":{"$date":"' datestr8601(q.t2, '*ymdHMS3') 'Z"}}}'];
else
    timeDat = '';
end
%{
if isfield(q, 'f1') && isfield(q, 'f2')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}},{maxFreq:{$lte:' num2str(q.f2) '}}'];
elseif isfield(q, 'f1')
    freqDat = [',{minFreq:{$gte:' num2str(q.f1) '}}'];
elseif isfield(q, 'f2')
    freqDat = [',{maxFreq:{$lte:' num2str(q.f2) '}}'];
else
    freqDat = '';
end

if isfield(q, 'dur1') && isfield(q, 'dur2')
    durDat = [',{duration:{$gte:' num2str(q.dur1) ', $lte:' num2str(q.dur2) '}}'];
elseif isfield(q, 'dur1')
    durDat = [',{duration:{$gte:' num2str(q.dur1) '}}'];
elseif isfield(q, 'dur2')
    durDat = [',{duration:{$lte:' num2str(q.dur2) '}}'];    
else
    durDat = '';
end

if isfield(q, 'lp1') && isfield(q, 'lp2')
    lpDat = [',{logProb:{$gte:' num2str(q.lp1) ', $lte:' num2str(q.lp2) '}}'];
elseif isfield(q, 'lp1')
    lpDat = [',{logProb:{$gte:' num2str(q.lp1) '}}'];
elseif isfield(q, 'lp2')
    lpDat = [',{logProb:{$lte:' num2str(q.lp2) '}}'];    
else
    lpDat = '';
end
%}

if isfield(q, 'loc') && isfield(q, 'rad')
    locDat = [',{"location":{"$geoWithin":{"$centerSphere":[[' num2str(q.loc(2)) ',' num2str(q.loc(1)) '], ' num2str(q.rad/earthRad) ']}}}'];
else
    locDat = '';
end

if isfield(q, 'tag')
    tagDat = [',{"$text": {"$search":"' q.tag '"}}'];
else
    tagDat = '';
end

%postDat = ['{$and:[' timeDat freqDat durDat lpDat locDat tagDat ']}'];
postDat = ['{"$and":[' timeDat locDat tagDat ']}'];

tmp = urlread2(['http://' servAddr ':8956/query?' queryString], 'POST', postDat, [], 'READ_TIMEOUT', 15000);
file = loadjson(tmp);
