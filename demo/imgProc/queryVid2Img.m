% Example scripts to use IlliadAccess and query video to 
% run face recognition algorithm
% Jae Yong Lee
% University of Illinois
% lee896@illinois.edu
%
% vidNUm = maximum number of videos to be queried
% year1,month1,date1 = yyyy,mm,dd, for begining date for query
% year2,month2,date2 = yyyy,mm,dd, for ending date for query

function imageCells = queryVid2Img(vidNum, year1, month1, date1,year2, month2, date2)
% add paths for additional functions
addpath(genpath('../../MATLAB'));
addpath(genpath('../../jsonlab'));
addpath(genpath('../../V1_1_urlread2'));

% Import cert into Matlab jvm truststore.
% Default alias is mykey
% Need write access to the truststore (cacerts)
% Only need to do this once per Matlab copy.
%importcert('../MATLAB/illiad.crt')

DB = 'publicDb';
USER = 'publicUser';
PWD = 'publicPwd';

%remove old data to write new data
workingDir = './temp/';
if exist(workingDir, 'dir')
    rmdir(workingDir,'s')
else
    mkdir(workingDir)
end

mkdir(workingDir,'vids')
mkdir(workingDir,'images')
imageDir = './temp/images/';

% Query file list from the database, limited to max 24 files
q.limit = vidNum;
q.t1 = datenum(year1,month1,date1,0,0,0); 
q.t2 = datenum(year2,month2,date2,0,0,0);
q.loc(1) = 40.1069855; q.loc(2) = -88.2244681; q.rad = 1;
events = IllQueryCol(DB, USER, PWD, 'v_event', q);
% Download array of available raw data
vidData=cell(1);
imageCells = cell(1);
dataID = cell(1);
for n = 1:size(events,2);
    if(isempty(events{n}))
        continue
    end
    vidData{n} =  IllDownGrid(DB, USER, PWD, 'v_data', events{n}.filename);
    waitfor(vidData{n});
    vidfilename = [sprintf('%03d',n) '.mp4'];
    vidfullname = fullfile(workingDir,'vids',vidfilename);
    dlmwrite(vidfullname,vidData{n},'');
    try
        vidObj = VideoReader(vidfullname);
    catch err
        disp('error reading video');
        dirp(err);
        continue;
    end
    % Write the video to img files
    ii = 1;
    mkdir(imageDir,int2str(n))
    imageNames = [];
    while hasFrame(vidObj)
        img = readFrame(vidObj);
        imgfilename = [sprintf('%03d',ii) '.jpg'];
        imgfullname = fullfile(imageDir,int2str(n),imgfilename);
        imwrite(img,imgfullname);
        imageNames = [imageNames; imgfullname];
        ii = ii+1;
    end
    
    % Read written image files to array
   % imageNames = dir(fullfile(imageDir,int2str(n),'*.jpg'));
    %imageNames.name
    imageCells{n} = imageNames;
    
   
    % Write event descriptor
    dataID{n} = IllDownCol(DB, USER, PWD, 'v_event', events{n}.filename);
    datafullname = fullfile(imageDir,int2str(n),'vidData.txt');
    dlmwrite(datafullname,savejson(dataID{n}),'');
    
end
disp('image save/load completed');

