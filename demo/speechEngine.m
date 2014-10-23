% Speech detection engine.
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%

clear all; close all;
delete(instrfind);

addpath(genpath('../matlab'));

mTcp = tcpip('localhost', 8086); % remote host and port
mTcp.InputBufferSize = 2^16;
mTcp.BytesAvailableFcnMode = 'terminator';
mTcp.Terminator = 'LF';
fopen(mTcp);

%% Periodically poll database for events
DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

period = 2.0;% in second
lastTime = now;
while(1)
    %try
        pause(period);
        
        % periodic query
        q.t1 = lastTime+1/864000; q.t2 = now;
        q.f2 = 7000;
        q.dur1 = 0.3; 
        q.lnp2 = -1e3;
        fprintf(1, sprintf('polling with t1: %s, t2: %s\n', datestr8601(q.t1), datestr8601(q.t2)));
        try
            events = IllQueryEvent(DB, USER, PWD, q);
            if (~iscell(events))
                continue;
            end
        catch e
            fprintf(2, sprintf('%s\n', e.message));
            continue;
        end
        
        disp('Found data, start processing...')
        for k = 1:numel(events)
            lastTime = datenum8601(events{k}.recordDate.x0x24_date)-5/24; % last acquired file, local time
            
            try
                [data, y, header] = IllDownData(DB, USER, PWD, events{k}.filename);
                fs = double(header.sampleRate);
            catch e
                fprintf(2, sprintf('%s\n', e.message));
                continue;
            end
            
            % Run vad
            vs = vadsohn(y, fs);
            mean(vs)
            
            if (mean(vs) > 0.5)
                disp('Speech detected')
                msg = sprintf('POST / HTTP/1.0\nConnection: Keep-Alive\n\n');
                fprintf(mTcp, msg);
            else
                disp('Not speech!!!')
            end
        end
    %catch e
    %    disp('error');
    %end
end