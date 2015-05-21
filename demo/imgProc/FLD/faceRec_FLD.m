%% Read all image and label
addpath(genpath('./'));
labels = [];
numImgs = 0;
fid = fopen(strcat(fileparts(pwd),'/imgProc/testingCases/labels.txt'));

tline = fgetl(fid);
while ischar(tline)
    numImgs = numImgs+1;
    labels = [labels tline];
    tline = fgetl(fid);
end
fclose(fid);

imageArray = cell(numImgs,2);
for imageID = 1:numImgs
    imageArray{imageID,1} = imread(strcat(fileparts(pwd),'/imgProc/testingCases/image',num2str(imageID),'.jpg'));
    imageArray{imageID,2} = labels(imageID);
end

%% Randomize array and obtain faceObjs/avgFaces
randomImageArray = imageArray(randperm(numImgs),:);


%declare detector and query images
faceDetector = vision.CascadeObjectDetector;
faceObjects = cell(1,3);

%set size of face image
sizeOfFace = [200,200];
%run loops for all videos to extract faces and save it on face Object

faceNum = 0;
sumFace = zeros(200,'double');
[numImage,aa] = size(randomImageArray);
for imageID = 1:numImage
    %step by step extract faces from imageArray
    bboxes = step(faceDetector,randomImageArray{imageID,1});
    [numFaces,rectsize] = size(bboxes);
    %faceObjects
    for faceID = 1:numFaces
        faceNum = faceNum+1;
        % face image
        faceObjects{faceNum,1} = double(rgb2gray(imresize(imcrop(randomImageArray{imageID,1}, bboxes(faceID,:)),sizeOfFace)));
        % image label
        faceObjects{faceNum,2} = randomImageArray{imageID,2};
        % image ID (to backtrack for original image)
        faceObjects{faceNum,3} = imageID; 
    end
end


%% normalize faces
faceMatrix = [];
averageFace = zeros(200,'double');
faceLabel = [];
for faceID = 1:faceNum
   averageFace  = averageFace + faceObjects{faceNum,1};
end
for faceID = 1:faceNum
   faceMatrix = [faceMatrix; imresize(faceObjects{faceID,1}-averageFace,[1,40000])];
   faceLabel = [faceLabel; char2label(faceObjects{faceID,2})];
end
faceMatrix = faceMatrix';
%% FLD(used for testing only)
[V, data_fld] = computeFLD(faceMatrix, faceLabel, 10);
params.k = 2;
class = classifyFace(data_fld(:,1:10)',data_fld(:,11:51)',faceLabel(11:51),'svm',params);
