% status = lightOn(BRIDGEIP, USERID, LIGHTID, cmd)
% Control the Phillips light on/off
% cmd is boolean
%
% Long Le
% University of Illinois
%
function status = lightOn(BRIDGEIP, USERID, LIGHTID, cmd)

if cmd
	cmdstr = 'true';
else
    cmdstr = 'false';
end
header = http_createHeader('Content-Type', 'application/json');
status = urlread2(['http://' BRIDGEIP '/api/' USERID '/lights/' LIGHTID '/state'], 'PUT', ['{"on":' cmdstr '}'], header);