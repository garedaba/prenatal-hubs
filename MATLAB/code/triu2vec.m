function [vec,ind] = triu2vec(mat,k)

if nargin < 2
    k = 1;
end

% This function simply gets the upper triangle of a matrix and converts it
% to a vector
onesmat = ones(size(mat));
UT = triu(onesmat,k);
vec = mat(UT == 1);
ind = find(UT == 1);
end