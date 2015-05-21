%% Read all image and label
addpath(genpath('./'));
labels = [];
numImgs = 0;

fid = fopen('./testingCases/labels.txt');

tline = fgetl(fid);
while ischar(tline)
    numImgs = numImgs+1;
    labels = [labels tline];
    tline = fgetl(fid);
end
fclose(fid);

imageArray = cell(numImgs,2);
for imageID = 1:numImgs
    imageArray{imageID,1} = imread(strcat('./testingCases/image',num2str(imageID),'.jpg'));
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


%% using FLD (not written by me)
% faceMatrix = [];
% averageFace = zeros(200,'double');
% faceLabel = [];
% for faceID = 1:faceNum
%    averageFace  = averageFace + faceObjects{faceNum,1};
% end
% for faceID = 1:faceNum
%    faceMatrix = [faceMatrix; imresize(faceObjects{faceID,1}-averageFace,[1,40000])];
%    faceLabel = [faceLabel; char2label(faceObjects{faceID,2})];
% end
% faceMatrix = faceMatrix';
% FLD(used for testing only)
% [V, data_fld] = computeFLD(faceMatrix, faceLabel, 10);
% params.k = 2;
% class = classifyFace(data_fld(:,1:10)',data_fld(:,11:51)',faceLabel(11:51),'svm',params);
% 
% %% divide array into 5 for 5-fold test
% 
% imageIDs = mat2cell(linspace(1,faceNum,faceNum),[1],[ceil(faceNum/5),ceil(faceNum/5),ceil(faceNum/5),ceil(faceNum/5),faceNum - (4*ceil(faceNum/5))]);
% 
%     

%% obtain average faces and substract/vectorize

avgFace = cell(5,1);
testingIDs = cell(5,1);
trainingIDs = cell(5,1);
for arrayID = 1:5
    trainingID = [];
    for array2ID = 1:5
        if(arrayID ~= array2ID)
            trainingID = [trainingID cell2mat(imageIDs(array2ID))];
        else
            testingIDs{arrayID} = cell2mat(imageIDs(array2ID));
        end
    end
    trainingIDs{arrayID} = trainingID;
end

for arrayID = 1:5
    sumFace = zeros(200,'double');
    for imageID = trainingIDs{arrayID}
        sumFace = sumFace + faceObjects{imageID,1};
    end
    avgFace{arrayID} = sumFace/size(trainingIDs{arrayID},2);
end

faceVectorMatrix = cell(5,1);
for arrayID = 1:5
    faceVector = [];
    for imageID = trainingIDs{arrayID}
        faceVector = [faceVector; reshape(faceObjects{imageID,1} - avgFace{arrayID},[1,200*200])];
    end
    faceVectorMatrix{arrayID} = faceVector;
end

%% obtain PCA coefficients
pcaCoeffArray = cell(5,1);
pcaScoreArray = cell(5,1);
pcaEigenArray = cell(5,1);
eigenFaceArray = cell(5,1);

for arrayID = 1:5
    [pcaCoeffArray{arrayID},pcaScoreArray{arrayID},pcaEigenArray{arrayID}] = pca(faceVectorMatrix{arrayID});
    numF = size(pcaCoeffArray{arrayID},2);
    eigenFaceSubArray = cell(numF,1);
    for faceID = 1:numF
        eigenFaceSubArray{faceID} = reshape(pcaCoeffArray{arrayID}(:,faceID),[200,200]);
    end
    eigenFaceArray{arrayID} = eigenFaceSubArray;
end

%% obtain coefficients from all images using eigenvalues of pca
testingIndexID = cell(5,1);
testingLabels = cell(5,1);
testingCoeffs = cell(5,1);

trainingIndexID = cell(5,1);
trainingLabels = cell(5,1);
trainingCoeffs = cell(5,1);

for arrayID = 1:5
    testingIndex = cell(size(testingIDs{arrayID},2),1);
    testingLabel = cell(size(testingIDs{arrayID},2),1);
    testingCoeff = cell(size(testingIDs{arrayID},2),1);
    
    trainingIndex = cell(size(trainingIDs{arrayID},2),1);
    trainingLabel = cell(size(trainingIDs{arrayID},2),1);
    trainingCoeff = cell(size(trainingIDs{arrayID},2),1);
    
    faceVector = [];
    newID = 0;
    for imageID = testingIDs{arrayID}
        newID = newID + 1;
        testingIndex{newID} = imageID;
        testingLabel{newID} = faceObjects{imageID,2};
        testingCoeff{newID} = pcaCoeffArray{arrayID}\reshape(faceObjects{imageID,1} - avgFace{arrayID},[1,200*200])';
    end
    
    newID = 0;
    for imageID = trainingIDs{arrayID}
        newID = newID + 1;
        testingIndex{newID} = imageID;
        trainingLabel{newID} = faceObjects{imageID,2};
        trainingCoeff{newID} = pcaCoeffArray{arrayID}\reshape(faceObjects{imageID,1} - avgFace{arrayID},[1,200*200])';
    end
    testingIndexID{arrayID} = testingIndex;
    testingLabels{arrayID} = testingLabel;
    testingCoeffs{arrayID} = testingCoeff;
    trainingIndexID{arrayID} = trainingIndex;
    trainingLabels{arrayID} = trainingLabel;
    trainingCoeffs{arrayID} = trainingCoeff;
end

%% train classifier based on coefficients (svm with gaussian radial base kernal)

%sigmas = linspace(10,150);
sigmas = linspace(0,1,50)
overallAccuracies = cell(size(sigmas,2),1);

sigCount = 0;
for sig = 100
    overallAccuracy = 0;
    
    accuracy = cell(5,1);
    expLabels = cell(5,1);
    for arrayID = 1:5
        [accuracy{arrayID},expLabels{arrayID}] = svmGaussian( testingCoeffs{arrayID}, testingLabels{arrayID}, trainingCoeffs{arrayID}, trainingLabels{arrayID}, 0.01,sig,1);
        overallAccuracy = overallAccuracy + accuracy{arrayID};
    end
    sigCount = sigCount +1;
    overallAccuracies{sigCount} = (overallAccuracy/5);
    
end

%plot(sigmas,cell2mat(overallAccuracies),'linewidth',4,'color','r');

%% train classifier based on coefficients (perceptron)

%sigmas = linspace(10,150);
alphas = linspace(0,0.1);
overallAccuracies = cell(size(sigmas,2),1);

sigCount = 0;
for alpha = 0.1
    overallAccuracy = 0;
    
    accuracy = cell(5,1);
    expLabels = cell(5,1);
    for arrayID = 1:5
        [accuracy{arrayID},expLabels{arrayID}] = perceptron( cellfun(@(x) x(1:30),testingCoeffs{arrayID},'UniformOutput',0), testingLabels{arrayID}, cellfun(@(x) x(1:30),trainingCoeffs{arrayID},'UniformOutput',0), trainingLabels{arrayID}, alpha, 1);
        overallAccuracy = overallAccuracy + accuracy{arrayID};
    end
    sigCount = sigCount +1;
    overallAccuracies{sigCount} = (overallAccuracy/5);
    
end

%plot(alphas,cell2mat(overallAccuracies),'linewidth',4,'color','r');


%% obtain confusion matrix.

confusionMatrices = cell(5,1);

for arrayID = 1:5
    confusionMatrices{arrayID} = labelsToMatrix(expLabels{arrayID},testingLabels{arrayID});
end

