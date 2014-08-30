% file = IllTimeQuery(db, user, pwd, varargin)
% Time query the Illinois acoustic server. 
%
% Ex:   varargin{1} = datenum(2014,8,3,16,22,44)
%       varargin{2} = datenum(2014,8,3,16,22,55) or limit (string)
% A limit of 0 is equivalent to no limit.
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%
function file = IllTimeQuery(db, user, pwd,varargin)

% Adjust time zone from Central Time (US) to UTC
tZoneOffset = 5/24;
varargin{1} = varargin{1} + tZoneOffset;

params = {'dbname', db, 'colname', 'data.files', 'user', user, 'passwd', pwd};
if (nargin <= 4)
    queryString = http_paramsToString(params);
    tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', ['{uploadDate:{$gte:{$date:"' datestr8601(varargin{1}, '*ymdHMS3') 'Z"}}}'], [], 'READ_TIMEOUT', 10000);
else
    if (iscellstr(varargin(2)))
        params(end+1:end+2) = {'limit', varargin{2}};
        queryString = http_paramsToString(params);
        tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', ['{uploadDate:{$gte:{$date:"' datestr8601(varargin{1}, '*ymdHMS3') 'Z"}}}'], [], 'READ_TIMEOUT', 10000);
    else
        varargin{2} = varargin{2} + tZoneOffset;
        queryString = http_paramsToString(params);
        tmp = urlread2(['https://acoustic.ifp.uiuc.edu:8081/query?' queryString], 'POST', ['{uploadDate:{$gte:{$date:"' datestr8601(varargin{1}, '*ymdHMS3') 'Z"}, $lte:{$date:"' datestr8601(varargin{2}, '*ymdHMS3') 'Z"}}}'], [], 'READ_TIMEOUT', 10000);
    end
end
file = loadjson(tmp);