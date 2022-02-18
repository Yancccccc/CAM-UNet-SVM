% matReader reads custom MAT files containing 6 channel multispectral image 
% data.
%
%  IMAGE = matReader(FILENAME) returns the first 6 channels of the
%  Multispectral image saved in FILENAME.

% Copyright 2017 The MathWorks, Inc.
function data = matReader(filename)

    d = load(filename);
    f = fields(d);
    data = d.(f{1})(:,:,1:11);%1:6