% status = lightColor(BRIDGEIP, USERID, LIGHTID, cmd, varargin)
% Control the Phillips light's hue and sat level
%
% cmd is a string of 'set' or 'offset'
% varargin can either be [x, y] coordinates or hueVal and satVal
%
% Long Le
% University of Illinois
%
function status = lightColor(BRIDGEIP, USERID, LIGHTID, cmd, varargin)

if strcmp(cmd, 'offset')
    resp = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID]);
    tmp = loadjson(resp);
    currHue = tmp.state.hue;
    currSat = tmp.state.sat;
    currXY = tmp.state.xy;
    
    if (numel(varargin) <= 1)
        % Color by coord
        if ismatrix(varargin{1})
            coord = sprintf('[%.4f, %.4f]', varargin{1}+currXY);
            
            header = http_createHeader('Content-Type', 'application/json');
            status = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID '/state'], 'PUT', ...
                ['{"xy":' coord '}'], header);
        else
            disp('arg must be an array')
        end
    else
        % Color by hue and sat
        hueVal = varargin{1};
        satVal = varargin{2};

        header = http_createHeader('Content-Type', 'application/json');
        status = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID '/state'], 'PUT', ...
            ['{"hue":' num2str(currHue+hueVal) ', "sat":' num2str(currSat+satVal) '}'], header);
    end
elseif strcmp(cmd, 'set')
    if (numel(varargin) <= 1)
        % Color by coord
        if ismatrix(varargin{1})
            coord = sprintf('[%.4f, %.4f]', varargin{1});
            
            header = http_createHeader('Content-Type', 'application/json');
            status = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID '/state'], 'PUT', ...
                ['{"xy":' coord '}'], header);
        else
            disp('arg must be an array')
        end
    else
        % Color by hue and sat
        hueVal = varargin{1};
        satVal = varargin{2};
        
        header = http_createHeader('Content-Type', 'application/json');
        status = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID '/state'], 'PUT', ...
            ['{"hue":' num2str(hueVal) ', "sat":' num2str(satVal) '}'], header);
    end
else
    disp('Unknown cmd')
end
