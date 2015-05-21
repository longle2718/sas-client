function class = classifyFace(test,train,train_lbl,method,params)
%CLASSIFYFACE
%   Usage: class = classifyFace(test,train,train_lbl,method,params)
%   Classify a given test token (or set of tokens) using a specified
%   classification method.
%
%   Input:  test
%           - NxM matrix (or vector) where M is the number of feature 
%             dimensions and N is the number of test tokens.
%           train
%           - RxM matrix of training features where M is the number of 
%             feature dimensions (which should match test) and R is the 
%             number of training tokens.
%           train_lbl 
%           - Rx1 vector of labels that correspond with each training 
%             token.
%           method
%           - String the correponds with the desired classification method. 
%             Options are:
%               'knn'   k nearest neighbors
%               'svm'   support vector machine
%           params      
%           - Structure variable containing parameters relevant to the 
%             classifier selected by method.
%             +--------+--------------------------------------------------+
%             | METHOD | PARAMETER                                        |
%             +--------+--------------------------------------------------+
%             | 'knn'  | k - Number of nearest neighbors to compare with. |
%             +--------+--------------------------------------------------+
%             | 'svm'  | k - Number of nearest neighbors to compare with  |
%             |        |     for breaking ties.                           |
%             +--------+--------------------------------------------------+
%   Output: class       
%           - Nx1 vector of predicted labels for each of the corresponding
%             test tokens.
%
%   Written by: Sean Yen (seanyen1@gmail.com)
%   Created on: 5/5/2015
%   Last updated: 5/5/2015

if strcmp(method,'knn')
    class = knnclassify(test,train,train_lbl,params.k);
    return;
elseif strcmp(method,'svm')
    % compute SVM to discriminate for each label one versus all
    pred = zeros(size(test,1),numel(unique(train_lbl)));
    for i = unique(train_lbl')
        one_label = (train_lbl==i);
        S         = svmtrain(train,one_label);
        pred(:,i) = svmclassify(S,test);
    end
    
    % determine SVM votes
    row        = (sum(pred,2)==1);
    [col,~]    = find(pred(sum(pred,2)==1,:)');
    class      = zeros(size(test,1),1);
    class(row) = col;
    
    % if there are any ties, break them with knn
    for i = find(row'~=1)
        tests = find(pred(i,:));
        if isempty(tests)
            class(i) = knnclassify(test(i,:),train,train_lbl,params.k);
        else
            idx = ismember(train_lbl,tests);
            class(i) = knnclassify(test(i,:),train(idx,:),train_lbl(idx),params.k);
        end
    end
end
