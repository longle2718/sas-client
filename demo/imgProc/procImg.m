
%set maximum number of videos to query
numVid = 3;

%declare cell objects for images and faces
imgObjs= cell(1);
faceObjs = cell(1);
%declare detector and query images
faceDetector = vision.CascadeObjectDetector;
imageDirCells = queryVid2Img(numVid,2015,01,01,2015,10,31);
totalFaces = 1;

%run loops for all videos to extract faces and save it on face Object
for vidID = 1:numVid
    [h,w] = size(imageDirCells{vidID});
    for imgID = 1:h
         imgObjs{imgID} = imread(imageDirCells{vidID}(imgID,:));
         bboxes = step(faceDetector,imgObjs{imgID});
         [numFaces,rectsize] = size(bboxes);
         for faces = 1:numFaces
             faceObjs{totalFaces} = imcrop(imgObjs{imgID}, bboxes(faces,:));
             figure, imshow(faceObjs{totalFaces}), title('Detected faces');
             totalFaces = totalFaces +1;
         end
    end
end