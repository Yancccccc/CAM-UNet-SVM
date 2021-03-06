function lgraph = deeplabv3plusLayers(imageSize, numClasses, network, varargin)
% deeplabv3plusLayers Create DeepLab v3+ for semantic segmentation using deep learning.
%
%   DeepLab v3+ is a convolutional neural network for semantic image
%   segmentation. It uses an encoder-decoder architecture, dilated
%   convolutions, and skip connections to segment images.
%
%   The network returned by deeplabv3plusLayers must be trained using
%   trainNetwork from Deep Learning Toolbox before it can be used for
%   semantic segmentation.
%
%   layerGraph = deeplabv3plusLayers(imageSize, numClasses, network)
%   returns a DeepLab v3+ layer graph configured using the following
%   inputs:
%
%   Inputs
%   ------
%   imageSize    Size of the network image input size, specified as a
%                2-element vector [height width], or a three element vector
%                [height width 3].
%
%   numClasses   Number of classes the network is configured to classify.
%
%   network      Specify the name of network to use as the DeepLab v3+ base
%                network. Valid network names are listed below, and require
%                installation of the associated Add-On:
%
%                <a href="matlab:helpview('deeplearning','resnet18')">'resnet18'</a>
%                <a href="matlab:helpview('deeplearning','resnet50')">'resnet50'</a>,
%                <a href="matlab:helpview('deeplearning','mobilenetv2')">'mobilenetv2'</a>
%                <a href="matlab:helpview('deeplearning','xception')">'xception'</a>
%                <a href="matlab:helpview('deeplearning','inceptionresnetv2')">'inceptionresnetv2'</a>
%
%   [...] = deeplabv3plusLayers(___, Name, Value,...) specifies additional
%   name-value pair arguments described below:
%
%   'DownsamplingFactor'   The amount the input image is downsampled by the
%                          encoder section of DeepLab v3+. Valid values for
%                          output stride are 8 or 16. Increasing the
%                          downsampling improves accuracy at the cost of
%                          training and inference times, and vice versa.
%
%                          This is also referred to as "output stride" in:
%
%                          Chen, Liang-Chieh et al. "Encoder-Decoder with
%                          Atrous Separable Convolution for Semantic Image
%                          Segmentation." ECCV (2018).
%
%                          Default: 16
%
%   Notes
%   -----
%   Depth separable convolutions are used in the ASPP (atrous spatial
%   pyramid pooling) and decoder sub-networks when the base network is
%   xception or mobilenetv2. Otherwise, convolution layers are used.
%
%   Example 1: Create DeepLab v3+ based on ResNet-18.
%   -------------------------------------------------
%   % Create DeepLab v3+ based on ResNet-18.
%   imageSize = [480 640 3];
%   imageSize = [224 224 3];
%   numClasses = 8;
network = 'resnet50';
%   network = 'mobilenetv2';
  lgraph = deeplabv3plusLayers(imageSize, numClasses, network, ...
               'DownsamplingFactor', 16);
%
%   % Display network.
%   analyzeNetwork(lgraph)
%
%   Example 2: Train DeepLab v3+.
%   -----------------------------
%   % Load the triangle dataset images using an image datastore. The
%   % dataset has 200, 32-by-32, grayscale images of random triangles.
%   dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
%   imageDir = fullfile(dataSetDir, 'trainingImages');
%   imds = imageDatastore(imageDir);
%
%   % Load the triangle dataset pixel labels using a pixel label datastore.
%   labelDir = fullfile(dataSetDir, 'trainingLabels');
%   classNames = ["triangle", "background"];
%   labelIDs   = [255 0];
%   pxds = pixelLabelDatastore(labelDir, classNames, labelIDs);
%
%   % Create DeepLab v3+
%   imageSize = [256 256];
%   numClasses = numel(classNames);
%   lgraph = deeplabv3plusLayers(imageSize,numClasses,'resnet18');
%
%   % Combine image and pixel label data for training.  Set the
%   % 'OutputSize' to the network's input size to automatically resize
%   % images during training.
%   pximds = pixelLabelImageDatastore(imds,pxds,'OutputSize',imageSize,...
%       'ColorPreprocessing','gray2rgb');
%
%   % Specify training options. Lower MiniBatchSize to reduce memory usage.
%   opts = trainingOptions('sgdm',...
%       'MiniBatchSize',8,...
%       'MaxEpochs',3);
%
%   % Train network.
%   net = trainNetwork(pximds,lgraph,opts);
%
%   % Read a test image.
%   I = imread('triangleTest.jpg');
%
%   % Resize test image by a factor of imageSize./32 so that triangles in
%   % the test image are roughly the same size as triangles seen during
%   % training.
%   I = imresize(I,'Scale',imageSize./32);
%
%   % Segment the image.
%   C = semanticseg(I,net);
%
%   % Display results.
%   B = labeloverlay(I,C);
%   figure
%   imshow(B)
%
% See also fcnLayers, segnetLayers, unetLayers, semanticseg, trainNetwork,
%          pixelClassificationLayer, pixelLabelImageDatastore.

% References
% ----------
% [1] Chen, Liang-Chieh et al. "Encoder-Decoder with Atrous Separable
%     Convolution for Semantic Image Segmentation." ECCV (2018).

% Copyright 2019 The Mathworks, Inc.

% A DeepLab v3+ network has the following sections:
%
%             +---------+---------+
%             |Input    |         |
%             +-------------------+
%             +---------v---------+
%             |Feature extraction |
%             |Layers             +---------+
%             +-+-------+-------+-+         |
%               |       |       |           |
%               +-+-----------+-+           v
%                 |     |     |      +------+------+
%                 +-+-------+-+      |low Lvl feat.|
%                   |   |   |        |Layers       |
%                   +-------+        +------+------+
%                       |                   |
%                       |                   |
%                       v                   |
%                  +----+----+              |
%                  |ASPP     |              |
%                  +----+----+              |
%                       |                   |
%                  +---------+              |
%                  |    |    |              |
%                  |    |    |              |
%               +--+----+----+--+           |
%               |Decoder        | <---------+
%               |       |       |
%             +-+---------------+-+
%             |         |         |
%             |         |         |
%             +-------------------+
%             +---------v---------+
%             |Predictions        |
%             |                   |
%             +-------------------+

vision.internal.requiresNeuralToolbox(mfilename);
narginchk(3,5); %%???????????????????????????????????????????????????????????????3???5??????
args = iParseInputs(imageSize, numClasses, network, varargin{:});

% Construct layer graph
networkInfo = iPredefinedNetworkInfo(args.network);
lgraph = iLoadModelAsLayerGraph(args.network);

% Verify user imageSize is at least as big as the network's image input
% size.
iAssertImageSizeIsCompatibileWithNetwork(args.imageSize,lgraph,networkInfo.Name);

% Modify backbone network using below-indented functions
lgraph = iRemoveClassificationLayers(lgraph, networkInfo);
[lgraph,networkInfo] = iChangeInputSize(lgraph,args.imageSize,networkInfo);
lgraph = iFixMisalignment(lgraph, networkInfo);
lgraph = iReduceStrides(lgraph,networkInfo,args.DownsamplingFactor);
lgraph = iDilateNetwork(lgraph,networkInfo,args.DownsamplingFactor);

lgraph = iAddAspptoNetwork(lgraph, networkInfo, args.DownsamplingFactor, 256, args.UseDepthSeparableConv);
lgraph = iAddDecoderToNetwork(lgraph, networkInfo, args.DownsamplingFactor, args.numClasses, args.UseDepthSeparableConv);
lgraph = iAddSegmentationLayers(lgraph, networkInfo);
end


%--------------------------------------------------------------------------
function [networkInfo] = iPredefinedNetworkInfo(network)
% FeatureExtractionLayer - last layer in network before classification
%                          layers.
%
% LowLevelFeatureLayer   - last layer whose output size is downsampled by
%                          factor of 4.
%
% LastDownsamplingLayers - last layers that downsample
%
% SecondLastDownsamplingLayers - second to last layers that downsample


s.resnet50 = struct(...
    'Name',"resnet50",...
    'FeatureExtractionLayer', "activation_49_relu", ...
    'LowLevelFeatureLayer', "activation_10_relu",...
    'LastDownsamplingLayers',["res5a_branch2a", "res5a_branch1"],...
    'SecondLastDownsamplingLayers',["res4a_branch2a", "res4a_branch1"]);

s.resnet18 = struct(...
    'Name',"resnet18",...
    'FeatureExtractionLayer', "res5b_relu", ...
    'LowLevelFeatureLayer', "res2b_relu",...
    'LastDownsamplingLayers',["res5a_branch2a", "res5a_branch1"],...
    'SecondLastDownsamplingLayers',["res4a_branch2a", "res4a_branch1"]);

% MobileNet v2: Choose second to last output layer as feature extractor to
% reduce cost of computation, as done in:
%
%   Sandler, Mark, et al. "Mobilenetv2: Inverted residuals and linear
%   bottlenecks." 2018 IEEE/CVF Conference on Computer Vision and Pattern
%   Recognition. IEEE, 2018.
s.mobilenetv2 = struct(...
    'Name',"mobilenetv2",...
    'FeatureExtractionLayer', "block_16_project_BN", ...
    'LowLevelFeatureLayer', "block_3_expand_relu",...
    'LastDownsamplingLayers',"block_13_depthwise",...
    'SecondLastDownsamplingLayers',"block_6_depthwise");

s.xception = struct(...
    'Name',"xception",...
    'FeatureExtractionLayer', "block14_sepconv2_act", ...
    'LowLevelFeatureLayer', "add_1",...
    'LastDownsamplingLayers',["block13_pool","conv2d_4"],...
    'SecondLastDownsamplingLayers',["block4_pool","conv2d_3"]);

s.inceptionresnetv2 = struct(...
    'Name',"inceptionresnetv2",...
    'FeatureExtractionLayer', "conv_7b_ac", ...
    'LowLevelFeatureLayer', "activation_5",...
    'LastDownsamplingLayers',["conv2d_158","conv2d_160","conv2d_163","max_pooling2d_4"],...
    'SecondLastDownsamplingLayers',["conv2d_73","conv2d_76","max_pooling2d_3"]);

if nargin == 0
    networkInfo = s;
else
    networkInfo = s.(network);
    networkInfo.DecoderOutputLayer = "dec_crop2";
    networkInfo.PixelClassificationLayer = "classification";
    networkInfo.AsppTail = 'catAspp';
end

end

%--------------------------------------------------------------------------
function args = iParseInputs(varargin)

p = inputParser;
p.addRequired('imageSize',  @iCheckImageSize);
p.addRequired('numClasses', @iCheckNumClasses);
p.addRequired('network',    @iCheckNetwork);
p.addParameter('DownsamplingFactor', 16, @iCheckDownsamplingFactor);

p.parse(varargin{:});

userInput = p.Results;

args.imageSize  = double(userInput.imageSize);
args.numClasses = double(userInput.numClasses);
args.network = string(userInput.network);
args.DownsamplingFactor = double(userInput.DownsamplingFactor);

% Append 3 if imageSize is 2-element vector
if numel(args.imageSize) == 2
    args.imageSize = [args.imageSize 3];
end

% Use depth separable conv in ASPP and decoder sub-networks for xception
% and mobilenet v2. 
if any(strcmp(args.network,["xception" "mobilenetv2"])) %%???????????????
    args.UseDepthSeparableConv = true;
else
    args.UseDepthSeparableConv = false;
end
end

%% Load backbone network
function lgraph = iLoadModelAsLayerGraph(modelName)
try
    net = feval(modelName);
    lgraph = iNetworkToLgraph(net);
catch ME
    throwAsCaller(ME)
end
end

%--------------------------------------------------------------------------
function lgraph = iNetworkToLgraph(network)
switch class(network)
    case 'SeriesNetwork'
        lgraph = layerGraph(network.Layers);
    case {'DAGNetwork','nnet.cnn.layer.Layer'}
        lgraph = layerGraph(network);
    case 'nnet.cnn.LayerGraph'
        lgraph = network;
    otherwise
        error('unknown network type');
end
end

%--------------------------------------------------------------------------
function lgraph = iRemoveClassificationLayers(lgraph, networkInfo)
layerList = iFindIntermediateLayers(lgraph,networkInfo.FeatureExtractionLayer);
lgraph = removeLayers(lgraph,layerList);
end

%--------------------------------------------------------------------------
function [lgraph,networkInfo] = iChangeInputSize(lgraph, imageSize,networkInfo)
idx = arrayfun(@(x)strcmp(class(x),"nnet.cnn.layer.ImageInputLayer"),lgraph.Layers);
oldL = lgraph.Layers(idx);
newLayer = vision.internal.cnn.utils.updateImageLayerInputSize(oldL,imageSize);
lgraph = replaceLayer(lgraph,lgraph.Layers(idx).Name,newLayer);
networkInfo.InputLayerName = oldL.Name;
end

%--------------------------------------------------------------------------
function lgraph = iFixMisalignment(lgraph, networkInfo)
% Fix misalignment by changing downsampling layers with asymmetrical
% padding to have 'same' padding.
switch networkInfo.Name
    case "resnet50"
        lgraph = iAlignResNet50(lgraph);
    case "resnet18"
        % no-op
    case "mobilenetv2"
        % no-op
    case "xception"
        lgraph = iAlignXception(lgraph);
    case "inceptionresnetv2"
        lgraph = iAlignInceptionResNetV2(lgraph);
    otherwise
        assert(false, 'unsupported network');
end

% second to last downsampling layers should also be set to have 'same'.
% These are not modified is DownsamplingFactor is 16 so we must do it here.
layers = networkInfo.SecondLastDownsamplingLayers;
for i = 1:numel(layers)
    layer = iFindLayer(lgraph,layers(i));
    lgraph = iUseSamePadding(lgraph,layer);
end
end

%--------------------------------------------------------------------------
function lgraph = iAlignResNet50(lgraph)
oldLayer = iFindLayer(lgraph,'max_pooling2d_1');
newLayer = iUpdateMaxPoolingLayer(oldLayer,'Padding','same');
lgraph = replaceLayer(lgraph,oldLayer.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iAlignXception(lgraph)
% Update block1_conv1 to use 'same' padding.
oldL = iFindLayer(lgraph,'block1_conv1');
newLayer = iUpdateConvLayer(oldL,'Padding','same');
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);

% Update block1_conv2 to use 'same' padding.
oldL = iFindLayer(lgraph,'block1_conv2');
newLayer = iUpdateConvLayer(oldL,'Padding','same');
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iAlignInceptionResNetV2(lgraph)

convLayers = ["conv2d_1","conv2d_2","conv2d_5"];
for i = 1:numel(convLayers)
    oldL = iFindLayer(lgraph,convLayers(i));
    newLayer = iUpdateConvLayer(oldL,'Padding','same');
    lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

poolLayers = ["max_pooling2d_1", "max_pooling2d_2"];
for i = 1:numel(poolLayers)
    oldL = iFindLayer(lgraph,poolLayers(i));
    newLayer = iUpdateMaxPoolingLayer(oldL,'Padding','same');
    lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end
end

%--------------------------------------------------------------------------
function newLayer = iUpdateMaxPoolingLayer(oldLayer, varargin)
% Extract padding value from the old layer.
padVal = iPadValFromMode(oldLayer);

p = inputParser;
p.addParameter('Stride',oldLayer.Stride);
p.addParameter('Padding',padVal);

p.parse(varargin{:});

newLayer = maxPooling2dLayer(oldLayer.PoolSize,...
    'Stride',p.Results.Stride,...
    'Name',oldLayer.Name,...
    'Padding',p.Results.Padding);

end

%--------------------------------------------------------------------------
function newLayer = iUpdateAvgPoolingLayer(oldLayer, varargin)
% Extract padding value from the old layer.
padVal = iPadValFromMode(oldLayer);

p = inputParser;
p.addParameter('Stride',oldLayer.Stride);
p.addParameter('Padding',padVal);

p.parse(varargin{:});

newLayer = averagePooling2dLayer(oldLayer.PoolSize,...
    'Stride',p.Results.Stride,...
    'Name',oldLayer.Name,...
    'Padding',p.Results.Padding);

end

%--------------------------------------------------------------------------
function padVal = iPadValFromMode(layer)
% Extract padding value from the old layer.
if strcmp(layer.PaddingMode,'manual')
    padVal = layer.PaddingSize;
else
    padVal = layer.PaddingMode;
end
end

%--------------------------------------------------------------------------
function newLayer = iUpdateConvLayer(oldLayer, varargin)
% Update conv layer Stride, DilationFactor, or Padding. Copy all other
% properties.

padVal = iPadValFromMode(oldLayer);

p = inputParser;
p.addParameter('Stride',oldLayer.Stride);
p.addParameter('Padding',padVal);
p.addParameter('DilationFactor',oldLayer.DilationFactor);

p.parse(varargin{:});

newLayer = convolution2dLayer(oldLayer.FilterSize,oldLayer.NumFilters,...
    'Stride',p.Results.Stride,...
    'DilationFactor',p.Results.DilationFactor,...
    'Name',oldLayer.Name,...
    'Padding',p.Results.Padding,...
    'WeightLearnRateFactor',oldLayer.WeightLearnRateFactor,...
    'BiasLearnRateFactor',oldLayer.BiasLearnRateFactor,...
    'WeightsInitializer',oldLayer.WeightsInitializer,...
    'BiasInitializer',oldLayer.BiasInitializer,...
    'BiasL2Factor', oldLayer.BiasL2Factor,...
    'WeightL2Factor',oldLayer.WeightL2Factor);
newLayer.Weights = oldLayer.Weights;
newLayer.Bias = oldLayer.Bias;
end

%--------------------------------------------------------------------------
function newLayer = iUpdateGroupedConvLayer(oldLayer, varargin)
% Update conv layer Stride, DilationFactor, or Padding. Copy all other
% properties.

padVal = iPadValFromMode(oldLayer);

p = inputParser;
p.addParameter('Stride',oldLayer.Stride);
p.addParameter('Padding',padVal);
p.addParameter('DilationFactor',oldLayer.DilationFactor);

p.parse(varargin{:});

newLayer = groupedConvolution2dLayer(oldLayer.FilterSize,...
    oldLayer.NumFiltersPerGroup,oldLayer.NumGroups,...
    'Stride',p.Results.Stride,...
    'DilationFactor',p.Results.DilationFactor,...
    'Name',oldLayer.Name,...
    'Padding',p.Results.Padding,...
    'WeightLearnRateFactor',oldLayer.WeightLearnRateFactor,...
    'BiasLearnRateFactor',oldLayer.BiasLearnRateFactor,...
    'WeightsInitializer',oldLayer.WeightsInitializer,...
    'BiasInitializer',oldLayer.BiasInitializer,...
    'BiasL2Factor', oldLayer.BiasL2Factor,...
    'WeightL2Factor',oldLayer.WeightL2Factor);
newLayer.Weights = oldLayer.Weights;
newLayer.Bias = oldLayer.Bias;
end

%--------------------------------------------------------------------------
function lgraph = iReduceStrides(lgraph,networkInfo,downsamplingFactor)

% DF : downsamplingFactor.
% Reduce stride of the last pooling layer for all branches for DF = 16
for ilayerName=networkInfo.LastDownsamplingLayers
    oldLayer = iFindLayer(lgraph,ilayerName);
    lgraph = iReduceStridesOfLayer(lgraph,oldLayer);
end
% Reduce stride of the last 2nd pooling layer for all branches for DF = 8
if downsamplingFactor == 8
    for ilayerName=networkInfo.SecondLastDownsamplingLayers
        oldLayer = iFindLayer(lgraph,ilayerName);
        lgraph = iReduceStridesOfLayer(lgraph,oldLayer);
    end
end
end

%--------------------------------------------------------------------------
function lgraph = iUseSamePadding(lgraph,oldL)

if class(oldL) == "nnet.cnn.layer.MaxPooling2DLayer"
    newLayer = iUpdateMaxPoolingLayer(oldL,'Padding','same');
elseif class(oldL) == "nnet.cnn.layer.Convolution2DLayer"
    newLayer = iUpdateConvLayer(oldL,'Padding','same');
elseif class(oldL) == "nnet.cnn.layer.AveragePooling2DLayer"
    newLayer = iUpdateAvgPoolingLayer(oldL,'Padding','same');
elseif class(oldL) == "nnet.cnn.layer.GroupedConvolution2DLayer"
    newLayer = iUpdateGroupedConvLayer(oldL,'Padding','same');
else
    assert('unsupported layer type');
end
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iReduceStridesOfLayer(lgraph,oldL)

if oldL.Stride ~= 2
    % all networks supported by this function have Stride of 1 or 2.
    assert(false,'Expected Stride to be 1 or 2');
end

if class(oldL) == "nnet.cnn.layer.MaxPooling2DLayer"
    lgraph = iReduceStrideToOneForMaxPooling(lgraph,oldL);
elseif class(oldL) == "nnet.cnn.layer.Convolution2DLayer"
    lgraph = iReduceStrideToOneForConv(lgraph,oldL);
elseif class(oldL) == "nnet.cnn.layer.AveragePooling2DLayer"
    lgraph = iReduceStrideToOneForAvgPool(lgraph,oldL);
elseif class(oldL) == "nnet.cnn.layer.GroupedConvolution2DLayer"
    lgraph = iReduceStrideToOneFoGroupedConv(lgraph,oldL);
end

end

%--------------------------------------------------------------------------
function lgraph = iReduceStrideToOneForMaxPooling(lgraph,oldL)
% written to reduce stride = 2 to stride = 1
% assumes downsizing filter is symmetrical

if oldL.PoolSize ==1
    newLayer = iUpdateMaxPoolingLayer(oldL,'Stride',1,'Padding',0);
elseif oldL.PoolSize > 1
    newLayer = iUpdateMaxPoolingLayer(oldL,'Stride',1,'Padding','same');
end
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iReduceStrideToOneFoGroupedConv(lgraph,oldL)
% assumes downsizing filter is symmetrical
% written to reduce stride = 2 to stride = 1
if max(oldL.FilterSize) ==1
    newLayer = iUpdateGroupedConvLayer(oldL,'Stride',1,'Padding',0);
elseif max(oldL.FilterSize) > 1
    newLayer = iUpdateGroupedConvLayer(oldL,'Stride',1,'Padding','same');
end
newLayer.Weights = oldL.Weights;
newLayer.Bias = oldL.Bias;
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iReduceStrideToOneForConv(lgraph,oldL)
% assumes downsizing filter is symmetrical
% written to reduce stride = 2 to stride = 1
if max(oldL.FilterSize) ==1
    newLayer = iUpdateConvLayer(oldL,'Stride',1,'Padding',0);
elseif max(oldL.FilterSize) > 1
    newLayer = iUpdateConvLayer(oldL,'Stride',1,'Padding','same');
end
newLayer.Weights = oldL.Weights;
newLayer.Bias = oldL.Bias;
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iReduceStrideToOneForAvgPool(lgraph,oldL)
% written to reduce stride = 2 to stride = 1
% assumes downsizing filter is symmetrical

if oldL.PoolSize ==1
    newLayer = iUpdateAvgPoolingLayer(oldL,'Stride',1,'Padding',0);
elseif oldL.PoolSize > 1
    newLayer = iUpdateAvgPoolingLayer(oldL,'Stride',1,'Padding','same');
end
lgraph = replaceLayer(lgraph,oldL.Name,newLayer);
end

%--------------------------------------------------------------------------
function lgraph = iDilateNetwork(lgraph,networkInfo,downsamplingFactor)
% first dilation for all layers after the last pooling layer
lgraph = iDilateAfterPool(lgraph,networkInfo.LastDownsamplingLayers);
% dilate an extra time if DF = 8 for all layers after 2nd last pool
if downsamplingFactor == 8
    lgraph = iDilateAfterPool(lgraph,networkInfo.SecondLastDownsamplingLayers);
end
end

%--------------------------------------------------------------------------
function lgraph = iDilateAfterPool(lgraph,poolLayers)
% find all layers that come after the pooling layer
layersAfterPool = [];
for i = poolLayers
    layersAfterPool = [layersAfterPool,iFindIntermediateLayers(lgraph,i)]; %#ok<AGROW>
end
layersAfterPool = unique(layersAfterPool);

% find all Convolution2DLayers and GroupedConvolution2dLayers that come
% after the removed pooling layer
toDilate = [];
for i = layersAfterPool
    iLayer = iFindLayer(lgraph,i);
    if strcmp(class(iLayer),"nnet.cnn.layer.Convolution2DLayer") || strcmp(class(iLayer),"nnet.cnn.layer.GroupedConvolution2dLayer")
        if max(iLayer.FilterSize) > 1
            toDilate = [toDilate ,i]; %#ok<AGROW>
        end
    end
end
% multiply dilation of all layers in toDilate by 2
% the network assumes that the downsampling steps that were removed had a
% stride of 2 each.
for i = toDilate
    oldL = iFindLayer(lgraph,i);
    newLayer = iUpdateConvLayer(oldL,'Stride',1,'Padding','same','DilationFactor',2*oldL.DilationFactor);
    lgraph = replaceLayer(lgraph,i,newLayer);
end
end

%% Aspp module
% An ASPP module can be visualized as follows:
%
%                           |
%                 +-----+---+--+------+------------+
%                 |     |      |      |            |
%                 |     |      |      |            |
%                 v     v      v      v            v
%           +-----++ +--+---+ ++----+ +-----+ +----+-+
%           |ASPP  | |ASPP  | |ASPP | |ASPP | |ASPP  |
%           |Branch| |Branch| |Branch |Branch |Branch|
%           |D1    | |D6    | |D12  | |D18  | |GAP   |
%           +-----++ +--+---+ +--+--+ +--+--+ +---+--+
%                 |     |        |       |        |
%                 v     v        v       v        v
%           +-----+-----+--------+-------+--------+--+
%           |Depth concatenation                     |
%           +----------------------------------------+

function lgraph = iAddAspptoNetwork(lgraph, networkInfo, downsamplingFactor, numFilters, useDepthSeparableConv)

%Notes:
%----------------------------------------
% 1. nLayerInputChannels is needed to initialize weights despite being
% optional argument to convolution2dLayer
% 2. the asppDilationFactors in each branch are selected based on the
% network's downsampling factor. Both values are taken directly from the
% paper, selected from empirical testing.
% Twice the size of asppDilationFactors for a downsamplingFactor of 8,
% compensates for the loss of receptive field due to having been
% downsampled fewer times.
%----------------------------------------

switch downsamplingFactor
    case 16
        asppDilationFactors = [1, 6 ,12 ,18];
    case 8
        asppDilationFactors = [1, 12 ,24 ,36];
end
asppFilterSizes = [1, 3, 3, 3];

% create concatenation layer and connect it to the tail
tempLayer = depthConcatenationLayer(4,'Name',networkInfo.AsppTail);
lgraph = addLayers(lgraph,tempLayer);

% create all convolutional aspp branches
for i = 1:numel(asppDilationFactors)
    asppConvName = "aspp_Conv_" + string(i);
    branchFilterSize = asppFilterSizes(i);
    branchDilationFactor = asppDilationFactors(i);
    
    % reassign tempLayer to new conv layer
    if useDepthSeparableConv
        asppConvNameStart = asppConvName + "_depthwise";
        asppConvNameEnd = asppConvName + "_pointwise";
        tempLayer = [
            groupedConvolution2dLayer(branchFilterSize, 1, 'channel-wise',...
            'DilationFactor', branchDilationFactor, 'Padding','same',...
            'Name', asppConvNameStart,...
            'WeightsInitializer','glorot','BiasInitializer','zeros',...
            'BiasLearnRateFactor', 0,...
            'WeightLearnRateFactor', 10);
            
            convolution2dLayer(1, numFilters, ...
            'Padding',0, ...
            'Name', asppConvNameEnd,...
            'WeightsInitializer','glorot','BiasInitializer','zeros',...
            'BiasLearnRateFactor', 0,...
            'WeightLearnRateFactor', 10);
            ];
        
    else
        asppConvNameStart = asppConvName;
        asppConvNameEnd = asppConvName;
        tempLayer = convolution2dLayer(branchFilterSize, numFilters,...
            'DilationFactor', branchDilationFactor, 'Padding','same',...
            'Name', asppConvName,...
            'WeightsInitializer','glorot','BiasInitializer','zeros',...
            'BiasLearnRateFactor', 0, ...
            'WeightLearnRateFactor',10);
    end
    
    lgraph = addLayers(lgraph,tempLayer);
    
    % reassign tempLayer to new batch norm layer
    asppBNName = "aspp_BatchNorm_" + string(i);
    tempLayer = batchNormalizationLayer('Name',asppBNName);
    lgraph = addLayers(lgraph,tempLayer);
    
    % reassign tempLayer to new relu layer
    asppReluName = "aspp_Relu_" + string(i);
    tempLayer = reluLayer('Name',asppReluName);
    lgraph = addLayers(lgraph,tempLayer);
    
    lgraph = connectLayers(lgraph,networkInfo.FeatureExtractionLayer,asppConvNameStart);
    lgraph = connectLayers(lgraph,asppConvNameEnd,asppBNName);
    lgraph = connectLayers(lgraph,asppBNName,asppReluName);
    lgraph = connectLayers(lgraph,asppReluName,strcat(networkInfo.AsppTail,"/in",string(i)));
end
end

%% Decoder
% The Decoder module can be visualized as follows :
%
% +----------------+  +--------------------+--------+
% |ASPP Output     |  |LowLevelFeature      Layers  |
% +----------------+  +-----------------------------+
% +----------------+  +-----------------------------+
% |Preprocess      |  |Preprocess          |        |
% |ASPP Output     |  |Intermediate Layers |        |
% |                |  |                    |        |
% |Conv - BN - Relu|  |Conv - BN - Relu    |        |
% |                |  |                    |        |
% |                |  +-----------------------------+
% |                |                       |
% +----------------+                       |
% +----------------------------+           |
% |Upsample ASPP outputs  x 4  |           |
% +----------------------------+           |
% +----------------------------+           |
% |Concatenate     |           | <---------+
% +----------------------------+
% +----------------------------+
% | Conv |BN |Relu |           |
% | Conv |BN |Relu |           |
% +----------------------------+
% +-------------------------------------------+
% |                v                          |
% |Upsample final feature maps  x 4           |
% |Predict segmentation maps                  |
% +-------------------------------------------+
% +-------------------------------------------+
% |Output Prediction                          |
% +-------------------------------------------+

function lgraph = iAddDecoderToNetwork(lgraph, networkInfo, downsamplingFactor, numClasses, useDepthSeparableConv)
%Notes:
%----------------------------------------
% 1. Wrapper decoder function to enable additon of different types of
% decoder modules for model extensibility
%----------------------------------------
lgraph = iDecoderv3Plus(lgraph, networkInfo, downsamplingFactor, numClasses, useDepthSeparableConv);
end

%--------------------------------------------------------------------------
function lgraph = iDecoderv3Plus(lgraph, networkInfo, downsamplingFactor, numClasses, useDepthSeparableConv)
switch downsamplingFactor
    case 16
        bilinearUpsamplingFactor = [4 4];
    case 8
        bilinearUpsamplingFactor = [2 4];
    otherwise
        assert(0,'unsupported downsampling factor');
end
% preprocess aspp output before decoding
tempLayerArray = [
    convolution2dLayer(1,256,'Name','dec_c1','WeightLearnRateFactor',10,...
    'BiasInitializer','zeros','BiasLearnRateFactor',0);
    batchNormalizationLayer('Name','dec_bn1');
    reluLayer('Name','dec_relu1');
    iBilinearUpsamplingLayer(bilinearUpsamplingFactor(1), 256,'dec_upsample1')
    crop2dLayer('centercrop','Name','dec_crop1')];

lgraph = addLayers(lgraph,tempLayerArray);

% preprocess LowLevelFeatureLayer output before decoding
tempLayerArray = [
    convolution2dLayer(1,48,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c2','WeightLearnRateFactor',10);
    batchNormalizationLayer('Name','dec_bn2');
    reluLayer('Name','dec_relu2')];

lgraph = addLayers(lgraph,tempLayerArray);

tempLayerArray = depthConcatenationLayer(2,'Name',"dec_cat1");

if useDepthSeparableConv
    
    tempLayerArray = [
        tempLayerArray
        groupedConvolution2dLayer(3,1,'channel-wise','BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c3_depthwise','Padding','same','WeightLearnRateFactor',10);
        convolution2dLayer(1,256,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c3_pointwise','Padding',0,'WeightLearnRateFactor',10);
        batchNormalizationLayer('Name','dec_bn3');
        reluLayer('Name','dec_relu3')
        groupedConvolution2dLayer(3,1,'channel-wise','BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c4_depthwise','Padding','same','WeightLearnRateFactor',10)
        convolution2dLayer(1,256,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c4_pointwise','Padding',0,'WeightLearnRateFactor',10)
        ];
else
    tempLayerArray = [
        tempLayerArray
        convolution2dLayer(3,256,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c3','Padding','same','WeightLearnRateFactor',10);
        batchNormalizationLayer('Name','dec_bn3');
        reluLayer('Name','dec_relu3')
        convolution2dLayer(3,256,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','dec_c4','Padding','same','WeightLearnRateFactor',10);
        ];
    
end

tempLayerArray = [
    tempLayerArray
    batchNormalizationLayer('Name','dec_bn4');
    reluLayer('Name','dec_relu4')
    convolution2dLayer(1,numClasses,'BiasInitializer','zeros','BiasLearnRateFactor',0,'Name','scorer','WeightLearnRateFactor',10)
    iBilinearUpsamplingLayer(bilinearUpsamplingFactor(2), numClasses,"dec_upsample2")
    crop2dLayer('centercrop','Name','dec_crop2')
    ];

lgraph = addLayers(lgraph,tempLayerArray);
lgraph = connectLayers(lgraph,networkInfo.AsppTail,'dec_c1');
lgraph = connectLayers(lgraph,'dec_relu2','dec_cat1/in1');
lgraph = connectLayers(lgraph,'dec_crop1','dec_cat1/in2');
lgraph = connectLayers(lgraph,networkInfo.LowLevelFeatureLayer,'dec_c2');
lgraph = connectLayers(lgraph,'dec_relu2','dec_crop1/ref');
lgraph = connectLayers(lgraph,networkInfo.InputLayerName,'dec_crop2/ref');
end

%--------------------------------------------------------------------------
function lgraph = iAddSegmentationLayers(lgraph, networkInfo)
tempLayerArray = [
    softmaxLayer('Name','softmax-out' );
    pixelClassificationLayer('Name',networkInfo.PixelClassificationLayer)
    ];
lgraph = addLayers(lgraph,tempLayerArray);
lgraph = connectLayers(lgraph,networkInfo.DecoderOutputLayer,'softmax-out');
end

%--------------------------------------------------------------------------
function upsamplingLayer = iBilinearUpsamplingLayer(scaleFactor, numFilters, name)
% Configure a transposed convolution layer for bilinear upsampling. Weights
% are frozen to bilinear interpolation weights.
%
% Upsampling can be done only by integer values, which avoids
% checkerboard artifacts.
numChannels = numFilters;
if isscalar(scaleFactor)
    scaleFactor = [scaleFactor, scaleFactor];
end

factor = scaleFactor;
filterSize = 2*factor - mod(factor,2);
cropping = (factor-mod(factor,2))/2;

upsamplingLayer = transposedConv2dLayer(filterSize,numFilters, ...
    'NumChannels',numChannels,'Stride',factor,'Cropping',cropping,'Name',name);

upsamplingLayer.Weights = vision.internal.cnn.bilinearUpsamplingWeights(filterSize,numChannels,numFilters);
upsamplingLayer.Bias = zeros(1,1,numFilters);

% Freeze weights and bias.
upsamplingLayer.WeightLearnRateFactor = 0;
upsamplingLayer.BiasLearnRateFactor = 0;

end

%--------------------------------------------------------------------------
function layerList = iFindIntermediateLayers(lgraph,head,tail)
% recursively searches through the DAG to find all layers between the head
% and tail layer, excluding head and tail layer themselves

% find all layers after head.
dg = vision.internal.cnn.RCNNLayers.digraph(lgraph);

id = findnode(dg,head);
ids = dfsearch(dg,id);
ids(1) = []; % exclude head node

tids = [];
if nargin == 3
    
    tid = findnode(dg,tail);
    tids = dfsearch(dg,tid);
    
end
intermediate = setdiff(ids,tids);

layerList = dg.Nodes.Name(intermediate,:)';
layerList = string(layerList);
end

%--------------------------------------------------------------------------
function layer = iFindLayer(lgraph,layerName)
% finds the layer corresponding to the layerName in lgraph.Layers
idx = arrayfun(@(x) strcmp(x.Name,layerName),lgraph.Layers);
layer = lgraph.Layers(idx);
end 

%--------------------------------------------------------------------------
function iCheckImageSize(x)
% Input should be RGB MxNx3 image.
% All the networks we will support have RGB input sizes.

validateattributes(x, {'numeric'}, ...
    {'vector', 'real', 'finite', 'integer', 'nonsparse', 'positive'}, ...
    mfilename, 'imageSize');

n = numel(x);
if n < 2 || n > 3
    error(message('vision:semanticseg:imageSizeIncorrect'));
end

% Third dim must be 3 for supported networks because they only support RGB
% images.
if n == 3 && x(3) ~= 3
    error(message('vision:semanticseg:imageSizeThirdDimMustBeThree'));
end
end

%--------------------------------------------------------------------------
function iCheckNumClasses(x)
validateattributes(x, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'integer', 'nonsparse', '>', 1}, ...
    mfilename, 'numClasses');
end

%--------------------------------------------------------------------------
function iCheckNetwork(x)
validateattributes(x,{'char','string'},{'scalartext'}, mfilename, 'name')
% Add new supported networks here
validStrings = iValidNetworkNames();
validatestring(x,validStrings.',mfilename,'name');
end

%--------------------------------------------------------------------------
function iCheckDownsamplingFactor(x)
hadError = false;
try
    validateattributes(x, {'numeric'}, ...
        {'positive','scalar', 'real', 'finite', 'integer', 'nonsparse'}, ...
        mfilename, 'DownsamplingFactor');
catch
    hadError = true;
end
if hadError || ~(x == 8 || x == 16)
    error(message('vision:semanticseg:invalidDownsamplingFactor'));
end
end

%--------------------------------------------------------------------------
function validNames = iValidNetworkNames()
networkInfoAll = iPredefinedNetworkInfo();
validNames = fields(networkInfoAll(:));
validNames = validNames.';
end

%--------------------------------------------------------------------------
function iAssertImageSizeIsCompatibileWithNetwork(imageSize, lgraph, networkName)

analysis = nnet.internal.cnn.analyzer.NetworkAnalyzer(lgraph);
imageLayerIdx = [analysis.LayerAnalyzers.IsInputLayer];
inputSize = analysis.LayerGraph.Layers(imageLayerIdx).InputSize;

if any(imageSize(1:2) < inputSize(1:2))
    error(message('vision:semanticseg:imageSizeInvalidForNetwork',...
        mat2str(inputSize(1:2)),networkName));
end
end
