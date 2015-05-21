function faces = imagePreprocess(ims,boxes,im_size,face_size)
%IMAGEPREPROCESS
%   Usage: faces = image_preprocess(ims,boxes,im_size,face_size)
%   Preprocesses raw images to be grayscale and of the same size given the
%   bounding box input.
%
%   Input:  ims       - PxN dimensional matrix where P is the number of 
%                       image dimensions and N is the number of unique 
%                       images.
%           boxes     - 4xN dimensional matrix where the upper-left and
%                       lower-right coordinates are given for each of the N
%                       unique images. The coordinates should be given with
%                       the order:
%                           upper-left x coordinate
%                           upper-left y coordinate
%                           lower-right x coordinate
%                           lower-right y coordinate
%           im_size   - A 2x1 vector that contains the size (height and
%                       width) of the raw image.
%           face_size - A 2x1 vector that contains the desired size to
%                       interpolate all of the face images to.
%   Output: faces     - MxN dimensional matrix where M is the
%                       dimensionality of the vectorized face image
%                       (prod(face_size)) and N is the number of unique
%                       images.
%
%   Written by: Sean Yen (seanyen1@gmail.com)
%   Created on: 5/5/2015
%   Last updated: 5/5/2015

% total number of images
total_ims = size(ims,2);

% keep only grayscale image
all_ims = ims(1:prod(im_size),:);

% convert bounding boxes from uint8 to int32
temp_box = zeros(4,total_ims);
for i = 1:4
    for j = 1:total_ims
        idx           = (i-1)*4+1;
        temp_box(i,j) = swapbytes(typecast(uint8(boxes(idx:idx+3,j)),'int32'));
    end
end
all_box = temp_box;  clear temp_box;

% extract face patches
all_face = zeros(prod(face_size),total_ims);
for i = 1:total_ims
    % compute indices corresponding with bounding box
    [x,y]         = meshgrid(all_box(1,i):all_box(3,i),all_box(2,i):all_box(4,i));
    idx           = sub2ind(im_size,x,y);
    % extract face
    face          = all_ims(idx(:),i);
    % normalize face
    face          = reshape(face,size(idx));
    face          = imresize(face,face_size,'bilinear');     % resize to constant size
    face          = (face(:)-mean(face(:)));                 % rescale image
    face          = face/std(face);
    
    all_face(:,i) = face;
end

faces = all_face;