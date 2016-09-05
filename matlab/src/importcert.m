% Import cert into Matlab jvm truststore.
% Need write access to the truststore (cacerts)
% Only need to do this once.
%importcert('illiad.crt')  
function importcert(filename)
    if (nargin == 0)
        % If no certificate specified show open file dialog to select
        [filename,path] = uigetfile({'*.cer;*.crt','Certificates (*.cer,*.crt)'},'Select Certificate');
        if (filename==0), return, end
        filename = fullfile(path,filename);
    end
    % Determine Java keytool location and cacerts location
    keytool = fullfile(matlabroot,'sys','java','jre',computer('arch'),'jre','bin','keytool');
    cacerts = fullfile(matlabroot,'sys','java','jre',computer('arch'),'jre','lib','security','cacerts');
    % Create backup of cacerts
    if (~exist([cacerts '.org'],'file'))
        copyfile(cacerts,[cacerts '.org'])
    end
    % Remove the old key if it already exists
    command = sprintf('"%s" -delete -alias "mykey" -keystore "%s" -storepass changeit',keytool,cacerts);
    dos(command);
    
    % Construct and execute keytool
    command = sprintf('"%s" -import -file "%s" -keystore "%s" -storepass changeit',keytool,filename,cacerts);
    dos(command);
    