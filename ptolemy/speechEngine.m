% Speech detection engine.
%
% Long Le
% University of Illinois
% longle1@illinois.edu
%

clear all; close all;
delete(instrfind);

addpath(genpath('../matlab'));
% Import cert into Matlab jvm truststore.
% Need write access to the truststore (cacerts)
% Only need to do this once.
%importcert('../matlab/jetty.crt')  

mTcp = tcpip('localhost', 8086); % remote host and port
mTcp.InputBufferSize = 2^16;
mTcp.BytesAvailableFcnMode = 'terminator';
mTcp.Terminator = 'LF';
fopen(mTcp);

%% Periodically poll database for events
DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

period = 1.0;% in second
lastTime = now;
while(1)
    %try
        disp('polling...')
        pause(period);
        
        % periodic query
        q.t1 = lastTime+1/864000; q.t2 = now;
        events = IllQueryEvent(DB, USER, PWD, q);
        if (~iscell(events))
            continue;
        end
        
        disp('Found data, start processing...')
        for k = 1:numel(events)
            lastTime = datenum8601(events{k}.uploadDate.x0x24_date)-5/24; % last acquired file, local time
            
            % Screen out unlikely event
            if (~(events{k}.duration >= 0.4 && ...
                    events{k}.maxFreq-events{k}.minFreq >=  1000 && ...
                    events{k}.logProbAbnom <= -6e2))
                disp('Unlikely, discard')
                continue;
            end
            
            % More likely to be an interesting event, get the raw data
            [data, y, header] = IllDownData(DB, USER, PWD, events{k}.filename);
            fs = double(header.sampleRate);
            
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