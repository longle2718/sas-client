function [V, data_fld] = computeFLD(data,lbl,N_fld)
%COMPUTEFLD
%   Usage: V = computeFLD(data,lbl,N_fld)
%   Compute the projection operator V for projecting face images into the
%   FLD subspace spanned by the given data.
%
%   Input:  data  - PxN dimensional matrix where P is the number of 
%                   image dimensions and N is the number of unique 
%                   images.
%           lbl   - N-element row vector containing the corresponding
%                   labels of each unique image in data.
%           N_fld - Integer number of FLD dimensions to project onto.
%   Output: V     - (N_fld-1)xP projection matrix for projecting other
%                   images onto the same FLD subspace.
%
%   Written by: Sean Yen (seanyen1@gmail.com)
%   Created on: 5/5/2015
%   Last updated: 5/5/2015

n = size(data,2);

% reduce dimensionality with PCA
[Vpca,~] = princomp(data);
Vpca     = data*Vpca;
Vpca     = Vpca./repmat(sqrt(sum(Vpca.^2,1)),[size(Vpca,1),1]);
Xpca     = Vpca(:,1:n-N_fld)'*data;

% compute mean vectors for each class
C = unique(lbl);
mu = zeros(size(Xpca,1),size(C,2));
for i = 1:size(C,2)
    mu(:,i) = mean(Xpca(:,lbl==C(i)),2);
end
MU = mean(mu,2);

% compute scatter matrix for each individual subject
Si = zeros(size(Xpca,1),size(Xpca,1),size(C,2));
for i = 1:size(C,2)
    x = Xpca(:,lbl==C(i));
    S = zeros(size(x,1),size(x,1),size(x,2));
    for j = 1:size(x,2)
        S(:,:,j) = (x(:,j)-mu(:,i))*(x(:,j)-mu(:,i))';
    end
    Si(:,:,i) = sum(S,3);
end

% compute within class scatter
Sw = sum(Si,3);

% compute between class scatter
S = zeros(size(Xpca,1),size(Xpca,1),size(C,2));
for i = 1:size(C,2)
    N        = size(Xpca(:,lbl==C(i)),2);
    S(:,:,i) = N*(mu(:,i)-MU)*(mu(:,i)-MU)';
end
Sb = sum(S,3);

% solve generalized eigenvector equation
[Vfld,~] = eig(Sb,Sw);

% compute FLD projection matrix
V = Vfld(:,1:N_fld-1)'*Vpca(:,1:n-N_fld)';

% project input data to the FLD subspace
data_fld = V*data;