% Voice/keyword detection App.
%
% Long Le
% University of Illinois
%

clear all; close all;
addpath(genpath('../../matlab'))

%% Periodically poll database for events
BRIDGEIP='128.174.226.140';
USERID='760f6fe5759c473d26b123f29e86b';
LIGHTID='2';
%LIGHTID='1';

DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

ACTUATE = false;

GOOGLE = true;

%% Offline
%{
%q.limit = 24;
q.t1 = datenum(2014,10,10,12,0,0); %q.t2 = datenum(2014,10,10,0,0,0); 
q.f2 = 6000;
q.dur1 = 0.6; 
%q.lnp2 = -6e2;        
events = IllQueryCol(DB, USER, PWD, 'event', q);

for k = 1:numel(events)
    disp('================================')
    disp(k)

    data = IllDownGrid(DB, USER, PWD, 'data', events{k}.filename);
    [y, header] = wavread_char(data);
    fs = double(header.sampleRate);

    % Run vad
    vs = vadsohn(y, fs);
    mean(vs)

    if (mean(vs) > 0.5)
        % Send to speech recog
        disp('Send to speech recog')

        if (GOOGLE)
            [tmp, resp] = gVoiceApi('AIzaSyD5NvcrQ54Rbzdxpo3FtJsAyvUjy6O3cn4', data);
            %[tmp, resp] = gVoiceApi('AIzaSyCnrAmwikHskQQ0LeEM-bp3TIx1pog9U40', data);
            %[tmp, resp] = gVoiceApi('AIzaSyDfTC6ep3rDM-PFD5NdtehR_CKhRqE8i7E', data);
            %[tmp, resp] = gVoiceApi('AIzaSyAThZrE-ox2VPc3fHYyBV2g2ThILAqCeaE', data);
        else
            [tmp, resp] = nASRApi('NMDPTRIAL_long_061220140812074638','7e43d074f2f5fd9bb41f3c987dd2c514d8ffeb8f88a325b77ad80a5d1d951f9bd8ef10cae40d66982da231aa74f6bf4cf5aadc7e4d0135c8d93f25f7d44492ac', data);
        end

        if (~iscell(resp))
            disp('Empty resp')
            continue;
        end
        
        % Allocate xscript space
        if (GOOGLE)
            numXscript = numel(resp{2}.result{1}.alternative);
        else
            numXscript = numel(resp{1});
        end
        xscript = cell(1, numXscript);
        for l = 1:numXscript
            if (GOOGLE)
                xscript{l} = resp{2}.result{1}.alternative{l}.transcript;
            else
                xscript{l} = resp{1}{l};
            end
            disp(xscript{l})
        end
        
        % Update event transcription
        for l = 1:numel(xscript)-1
            xscript{l} = [xscript{l} ' ']; % Add white space between xscript
        end
        resp = IllUpdateCol('publicDb', 'publicUser', 'publicPwd', 'event', events{k}.filename, 'set',['{transcript:"' cell2mat(xscript) '"}']);
    else
        disp('Not speech!!!')
    end
end
%}
%% Online
%[goodbyeW] = wavread('tmp/goodbye.wav');
%[helloW] = wavread('tmp/hello.wav');
%[okW, synfs] = wavread('tmp/ok.wav');
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
            events = IllQueryCol(DB, USER, PWD, 'event', q);
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
                data = IllDownGrid(DB, USER, PWD, 'data', events{k}.filename);
                [y, header] = wavread_char(data);
                fs = double(header.sampleRate);
            catch e
                fprintf(2, sprintf('%s\n', e.message));
                continue;
            end
            
            % Run vad
            vs = vadsohn(y, fs);
            mean(vs)
            
            if (mean(vs) > 0.5)
                % Send to speech recog
                disp('Send to speech recog')

				try 
	                if (GOOGLE)
    	                [tmp, resp] = gVoiceApi('AIzaSyD5NvcrQ54Rbzdxpo3FtJsAyvUjy6O3cn4', data);
        	            %[tmp, resp] = gVoiceApi('AIzaSyCnrAmwikHskQQ0LeEM-bp3TIx1pog9U40', data);
            	        %[tmp, resp] = gVoiceApi('AIzaSyDfTC6ep3rDM-PFD5NdtehR_CKhRqE8i7E', data);
                	    %[tmp, resp] = gVoiceApi('AIzaSyAThZrE-ox2VPc3fHYyBV2g2ThILAqCeaE', data);
                	else
                    	[tmp, resp] = nASRApi('NMDPTRIAL_long_061220140812074638','7e43d074f2f5fd9bb41f3c987dd2c514d8ffeb8f88a325b77ad80a5d1d951f9bd8ef10cae40d66982da231aa74f6bf4cf5aadc7e4d0135c8d93f25f7d44492ac', data);
	                end
				catch e
                	fprintf(2, sprintf('%s\n', e.message));
					continue;
				end
                
                if (~iscell(resp))
                    disp('Empty resp')
                    continue;
                end
                
                % Allocate xscript space
                if (GOOGLE)
                    numXscript = numel(resp{2}.result{1}.alternative);
                else
                    numXscript = numel(resp{1});
                end
                xscript = cell(1, numXscript);
                for l = 1:numXscript
                    if (GOOGLE)
                        xscript{l} = resp{2}.result{1}.alternative{l}.transcript;
                    else
                        xscript{l} = resp{1}{l};
                    end
                    disp(xscript{l})
                    
                    % Actuate
                    if (ACTUATE)
                        if ( ~isempty(strfind(xscript{l}, 'on')) )
                            disp('***** Light On')
                            %soundsc(helloW, synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 45000, 0);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'off')) )
                            disp('***** Light Off')
                            %soundsc(goodbyeW, synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, false);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'red')) )
                            disp('***** Red')
                            %soundsc([okW], synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 65000, 255);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'pink')) )
                            disp('***** Pink')
                            %soundsc([okW], synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 60000, 255);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'purple')) )
                            disp('***** Purple')
                            %soundsc([okW], synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 50000, 205);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'orange')) )
                            disp('***** Orange')
                            %soundsc([okW], synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 65000, 120);
                            break;
                        elseif ( ~isempty(strfind(xscript{l}, 'yellow')) )
                            disp('***** Yellow')
                            %soundsc(okW, synfs);
                            lightOn(BRIDGEIP, USERID, LIGHTID, true);
                            lightColor(BRIDGEIP, USERID, LIGHTID, 'set', 20000, 255);
                            break;
                        end
                    end
                end
                
                % Update event transcription
                for l = 1:numel(xscript)-1
                    xscript{l} = [xscript{l} ' ']; % Add white space between xscript
                end
                resp = IllUpdateCol('publicDb', 'publicUser', 'publicPwd', 'event', events{k}.filename, 'set',['{transcript:"' cell2mat(xscript) '"}']);
            else
                disp('Not speech!!!')
            end
        end
    %catch e
    %    disp('error');
    %end
end
