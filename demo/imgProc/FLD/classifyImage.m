function class = classifyImage(im,box,train_file)
%CLASSIFYIMAGE
%   Usage: class = classifyImage(im,box)
%   Given a raw image and a bounding box around the face, return the
%   predicted class.
%
%   Input:  im  
%           - Px1 vector of raw image data.
%           box   
%           - 16x1 vector containing the raw bounding box data.
%           train_file 
%           - A .mat file containing train_fld, train_lbl, V, im_size, and
%             face_size variables.
%   Output: class     
%           - Predicted class of the test token. Predicted class will be
%             returned corresponding to the labels in train_lbl.
%
%   Written by: Sean Yen (seanyen1@gmail.com)
%   Created on: 5/6/2015
%   Last updated: 5/6/2015

% internal parameters
method        = 'knn';
params.k      = 2;

% load training data
load(train_file);

% preprocess test token
test = imagePreprocess(im,box,im_size,face_size);

% project test token to FLD subspace of training data
test_fld = V*test;

% classify
class = classifyFace(test_fld',train_fld',train_lbl',method,params);