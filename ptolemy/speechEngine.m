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
db = 'publicDb';
user = 'publicUser';
pwd = 'publicPwd';

period = 1.0;% in second
lastTime = now;
while(1)
    %try
        disp('polling...')
        pause(period);
        
        % periodic query
        file = IllTimeQuery(db, user, pwd, lastTime+1/864000, now);
        if (~iscell(file))
            continue;
        end
        
        disp('Found data, start processing...')
        for k = 1:numel(file)
            lastTime = datenum8601(file{k}.uploadDate.x0x24_date)-5/24; % last acquired file, local time
            
            [data, y, header] = IllDownData(db, user, pwd, file{k}.filename);
            fs = double(header.sampleRate);
            event = IllDownEvent(db, user, pwd, file{k}.filename);
            if (~iscell(event))
                continue; % invalid event
            end
            
            % Screen out unlikely event
            if (~(event{1}.duration >= 0.4*event{1}.fs/event{1}.Nblk && ...
                    event{1}.bandwidth >=  1000/(event{1}.fs/2)*event{1}.Nfreq && ...
                    event{1}.logProbAbnom <= -6e2))
                disp('Unlikely, discard')
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